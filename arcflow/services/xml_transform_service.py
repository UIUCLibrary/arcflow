"""
Service for transforming and manipulating XML content.

Handles EAD and EAC-CPF XML transformations including:
- Adding creator IDs to origination elements
- Injecting collection metadata (record groups, subgroups, bioghist)
- Adding collection links to EAC-CPF resourceRelation elements
- Building bioghist XML elements from structured data
"""

import re
from typing import Optional, List
from xml.sax.saxutils import escape as xml_escape
from xml.etree import ElementTree as ET
import logging


class XmlTransformService:
    """Service for XML transformations and manipulations."""

    def __init__(self, client=None, log=None):
        """
        Initialize the XML transform service.

        Args:
            client: ASnake client for fetching resources (optional, needed for some operations)
            log: Logger instance (optional, creates default if not provided)
        """
        self.client = client
        self.log = log or logging.getLogger(__name__)

    def add_creator_ids_to_origination(self, xml_content: str, resource: dict, indent_size: int = 0) -> str:
        """
        Add authfilenumber attributes to name elements inside <origination> elements in EAD XML.

        Maps linked_agents with role='creator' to origination elements by index order.
        The authfilenumber value is a creator ID in the format creator_{type}_{id},
        which is a valid EAD attribute for authority file identifiers.

        Args:
            xml_content: EAD XML as a string
            resource: ArchivesSpace resource record with resolved linked_agents
            indent_size: Indentation size for logging

        Returns:
            str: Modified EAD XML string
        """
        indent = ' ' * indent_size

        # Extract creator IDs from linked_agents in order
        creator_ids = []
        for linked_agent in resource.get('linked_agents', []):
            if linked_agent.get('role') == 'creator':
                agent_ref = linked_agent.get('ref', '')
                match = re.match(r'.*/agents/(corporate_entities|people|families)/(\d+)$', agent_ref)
                if match:
                    creator_ids.append(f'creator_{match.group(1)}_{match.group(2)}')
                else:
                    self.log.warning(f'{indent}Could not parse creator ID from agent ref: {agent_ref}')

        if not creator_ids:
            return xml_content

        # Match origination elements; name elements within get authfilenumber in order
        origination_pattern = re.compile(r'<origination[^>]*>.*?</origination>', re.DOTALL)
        name_start_pattern = re.compile(r'<(corpname|persname|famname)((?:\s[^>]*)?)(>|/>)')

        result = []
        prev_end = 0
        creator_idx = 0

        for orig_match in origination_pattern.finditer(xml_content):
            result.append(xml_content[prev_end:orig_match.start()])
            orig_text = orig_match.group()

            if creator_idx < len(creator_ids):
                creator_id = creator_ids[creator_idx]
                name_match = name_start_pattern.search(orig_text)
                if name_match and 'authfilenumber' not in name_match.group(2):
                    new_tag = (f'<{name_match.group(1)}{name_match.group(2)}'
                               f' authfilenumber="{creator_id}"{name_match.group(3)}')
                    orig_text = orig_text[:name_match.start()] + new_tag + orig_text[name_match.end():]
                creator_idx += 1

            result.append(orig_text)
            prev_end = orig_match.end()

        result.append(xml_content[prev_end:])
        return ''.join(result)

    def inject_collection_metadata(
        self,
        xml_content: str,
        record_group: Optional[str],
        subgroup: Optional[str],
        bioghist_content: Optional[str]
    ) -> str:
        """
        Inject ArcFlow metadata into collection EAD XML after </did> tag.

        Adds:
        - Record group and subgroup classification labels
        - Biographical/historical notes from creator agents

        Args:
            xml_content: EAD XML as a string
            record_group: Record group label (e.g., "ALA 52 — Library Periodicals")
            subgroup: Subgroup label (e.g., "ALA 52.2 — Publications")
            bioghist_content: XML string of bioghist elements to inject

        Returns:
            str: Modified EAD XML string
        """
        insert_pos = xml_content.find('<archdesc level="collection">')

        if insert_pos == -1:
            return xml_content

        did_end_pos = xml_content.find('</did>', insert_pos)
        if did_end_pos == -1:
            return xml_content

        did_end_pos += len('</did>')
        extra_xml = ''

        # Add record group and subgroup labels
        if record_group:
            extra_xml += f'\n<recordgroup>{xml_escape(record_group)}</recordgroup>'
            if subgroup:
                extra_xml += f'\n<subgroup>{xml_escape(subgroup)}</subgroup>'

        # Handle biographical/historical notes
        if bioghist_content:
            archdesc_end = xml_content.find('</archdesc>', did_end_pos)
            search_section = (xml_content[did_end_pos:archdesc_end]
                            if archdesc_end != -1 else xml_content[did_end_pos:])

            existing_bioghist_end = search_section.rfind('</bioghist>')

            if existing_bioghist_end != -1:
                # Insert into existing bioghist
                insert_pos = did_end_pos + existing_bioghist_end
                xml_content = (xml_content[:insert_pos] +
                              f'\n{bioghist_content}\n' +
                              xml_content[insert_pos:])
            else:
                # Create new bioghist wrapper
                wrapped_content = f'<bioghist>\n{bioghist_content}\n</bioghist>'
                extra_xml += f'\n{wrapped_content}'

        if extra_xml:
            xml_content = (xml_content[:did_end_pos] +
                          extra_xml +
                          xml_content[did_end_pos:])

        return xml_content

    def add_collection_links_to_eac_cpf(self, eac_cpf_xml: str, indent_size: int = 0) -> str:
        """
        Add <descriptiveNote><p>ead_id:{ead_id}</p></descriptiveNote> to
        <resourceRelation resourceRelationType="creatorOf"> elements in EAC-CPF XML.

        For each creatorOf resourceRelation, fetches the linked ArchivesSpace resource
        to obtain its ead_id. If a resource cannot be fetched (deleted, unpublished, etc.),
        logs a warning and skips that collection link.

        Args:
            eac_cpf_xml: EAC-CPF XML as a string
            indent_size: Indentation size for logging

        Returns:
            str: Modified EAC-CPF XML string

        Raises:
            ValueError: If client is not configured (required for fetching resources)
        """
        if not self.client:
            raise ValueError("Client is required for add_collection_links_to_eac_cpf operation")

        indent = ' ' * indent_size

        # Match creatorOf resourceRelation elements (handles any attribute ordering)
        resource_relation_pattern = re.compile(
            r'(<resourceRelation\b[^>]*?\bresourceRelationType=["\']creatorOf["\'][^>]*?>)'
            r'(.*?)'
            r'(</resourceRelation>)',
            re.DOTALL
        )

        result = []
        prev_end = 0

        for match in resource_relation_pattern.finditer(eac_cpf_xml):
            result.append(eac_cpf_xml[prev_end:match.start()])

            opening_tag = match.group(1)
            content = match.group(2)
            closing_tag = match.group(3)

            # Idempotent: skip if our descriptiveNote with ead_id pattern already added
            # Check for the specific pattern we create: <descriptiveNote><p>ead_id:...</p></descriptiveNote>
            if re.search(r'<descriptiveNote>\s*<p>ead_id:[^<]+</p>\s*</descriptiveNote>', content):
                result.append(match.group(0))
                prev_end = match.end()
                continue

            # Extract xlink:href from opening tag
            href_match = re.search(r'xlink:href=["\']([^"\']+)["\']', opening_tag)
            if not href_match:
                result.append(match.group(0))
                prev_end = match.end()
                continue

            href = href_match.group(1)

            # Only process resource URLs (skip digital_objects, etc.)
            # Pattern: repositories/{number}/resources/{number}
            uri_match = re.search(r'/repositories/(\d+)/resources/(\d+)', href)
            if not uri_match:
                # Not a resource URL (likely digital_object or other type) - skip silently
                result.append(match.group(0))
                prev_end = match.end()
                continue

            res_repo_id = uri_match.group(1)
            res_resource_id = uri_match.group(2)

            # Fetch resource to get ead_id; skip on any error
            try:
                response = self.client.get(f'/repositories/{res_repo_id}/resources/{res_resource_id}')
                if response.status_code != 200:
                    self.log.warning(
                        f'{indent}Could not fetch resource {href}: HTTP {response.status_code}. '
                        'Skipping collection link.')
                    result.append(match.group(0))
                    prev_end = match.end()
                    continue

                resource = response.json()
                ead_id = resource.get('ead_id')
                if not ead_id:
                    self.log.warning(
                        f'{indent}Resource /repositories/{res_repo_id}/resources/{res_resource_id} '
                        'has no ead_id. Skipping collection link.')
                    result.append(match.group(0))
                    prev_end = match.end()
                    continue

                descriptive_note = (
                    f'\n    <descriptiveNote>\n'
                    f'      <p>ead_id:{ead_id}</p>\n'
                    f'    </descriptiveNote>'
                )
                result.append(opening_tag + content + descriptive_note + '\n  ' + closing_tag)

            except Exception as e:
                self.log.warning(f'{indent}Could not fetch resource for {href}: {e}. Skipping collection link.')
                result.append(match.group(0))

            prev_end = match.end()

        result.append(eac_cpf_xml[prev_end:])
        return ''.join(result)

    def build_bioghist_element(
        self,
        agent_name: str,
        persistent_id: Optional[str],
        paragraphs: List[str]
    ) -> str:
        """
        Build bioghist XML element from structured data.

        Args:
            agent_name: Name of the agent for the head element
            persistent_id: Persistent ID for the bioghist element (optional)
            paragraphs: List of paragraph strings (already wrapped in <p> tags)

        Returns:
            str: Bioghist XML element as a string
        """
        paragraphs_xml = '\n'.join(paragraphs)
        heading = f'Historical Note from {xml_escape(agent_name)} Creator Record'

        # Only include id attribute if persistent_id is available
        if persistent_id:
            id_attr = f' id="aspace_{persistent_id}"'
        else:
            id_attr = ''

        return (
            f'<bioghist{id_attr}>\n'
            f'  <head>{heading}</head>\n'
            f'  {paragraphs_xml}\n'
            f'</bioghist>'
        )

    def validate_eac_cpf_xml(self, eac_cpf_xml: str, agent_uri: str, indent_size: int = 0) -> Optional[ET.Element]:
        """
        Parse and validate EAC-CPF XML structure.

        Args:
            eac_cpf_xml: EAC-CPF XML as a string
            agent_uri: Agent URI for logging purposes
            indent_size: Indentation size for logging

        Returns:
            ElementTree root element if valid, None if parsing fails
        """
        indent = ' ' * indent_size

        try:
            root = ET.fromstring(eac_cpf_xml)
            self.log.debug(f'{indent}Parsed EAC-CPF XML root element: {root.tag}')
            return root
        except ET.ParseError as e:
            self.log.error(f'{indent}Failed to parse EAC-CPF XML for {agent_uri}: {e}')
            return None
