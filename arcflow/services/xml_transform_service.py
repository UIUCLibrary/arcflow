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

    def add_creator_ids_to_ead(self, ead: str, resource: dict, indent_size: int = 0) -> str:
        """
        Add arcuit:creator_id attributes to name elements inside <origination> elements in EAD XML.

        Uses a custom namespace (xmlns:arcuit="https://arcuit.library.illinois.edu/ead-extensions") to avoid
        collisions with standard EAD attributes like authfilenumber.

        Maps linked_agents with role='creator' to origination elements by index order.
        The arcuit:creator_id value is a creator ID in the format creator_{type}_{id}.

        Args:
            ead: EAD XML as a string
            resource: ArchivesSpace resource record with resolved linked_agents
            indent_size: Indentation size for logging

        Returns:
            str: Modified EAD XML string with arcuit namespace and creator_id attributes
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
            return ead

        try:
            # Define the Arcuit namespace
            arcuit_ns = "https://arcuit.library.illinois.edu/ead-extensions"
            ET.register_namespace('arcuit', arcuit_ns)

            # Parse the XML
            root = ET.fromstring(ead)
            namespace = ''
            if root.tag.startswith('{'):
                namespace = root.tag.split('}')[0] + '}'

            # Add arcuit namespace declaration to root element if not present
            if f'{{{arcuit_ns}}}' not in str(ET.tostring(root)):
                root.attrib[f'{{http://www.w3.org/2000/xmlns/}}arcuit'] = arcuit_ns

            # Find all origination elements with label="Creator"
            creator_idx = 0
            for origination in root.iter(f'{namespace}origination'):
                if origination.get('label') == 'Creator' and creator_idx < len(creator_ids):
                    creator_id = creator_ids[creator_idx]

                    # Find the first name element (corpname, persname, or famname)
                    name_elem = None
                    for tag in ['corpname', 'persname', 'famname']:
                        name_elem = origination.find(f'{namespace}{tag}')
                        if name_elem is not None:
                            break

                    if name_elem is not None:
                        # Add the arcuit:creator_id attribute (always, never skip)
                        name_elem.set(f'{{{arcuit_ns}}}creator_id', creator_id)
                        creator_idx += 1
                    else:
                        # No eligible name element found
                        self.log.debug(
                            f'{indent}No eligible name element in <origination> for creator ID {creator_id}'
                        )

            # Convert back to string
            result = ET.tostring(root, encoding='unicode', method='xml')
            return result

        except ET.ParseError as e:
            self.log.error(f'{indent}Failed to parse EAD XML: {e}. Returning original content.')
            return ead

    def inject_collection_metadata(
        self,
        ead: str,
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
            ead: EAD XML as a string
            record_group: Record group label (e.g., "ALA 52 — Library Periodicals")
            subgroup: Subgroup label (e.g., "ALA 52.2 — Publications")
            bioghist_content: XML string of bioghist elements to inject

        Returns:
            str: Modified EAD XML string
        """
        try:
            # Parse the XML
            root = ET.fromstring(ead)

            # Get the namespace, if any
            namespace = ''
            if root.tag.startswith('{'):
                namespace = root.tag.split('}')[0] + '}'
            
            archdesc = None
            for elem in root.iter(f'{namespace}archdesc'):
                if elem.get('level') == 'collection':
                    archdesc = elem
                    break
            
            if archdesc is None:
                return ead
            
            did = archdesc.find(f'{namespace}did')
            if did is None:
                return ead
            
            did_index = list(archdesc).index(did)
            insert_index = did_index + 1
            
            if record_group:
                recordgroup = ET.Element('recordgroup')
                recordgroup.text = record_group
                archdesc.insert(insert_index, recordgroup)
                insert_index += 1
                
                if subgroup:
                    subgroup_elem = ET.Element('subgroup')
                    subgroup_elem.text = subgroup
                    archdesc.insert(insert_index, subgroup_elem)
                    insert_index += 1
            
            if bioghist_content:
                existing_bioghist = None
                for elem in archdesc:
                    if elem.tag == 'bioghist':
                        existing_bioghist = elem
                        break
                
                try:
                    # Wrap in a temporary root to handle multiple bioghist elements
                    bioghist_wrapper = ET.fromstring(f'<wrapper>{bioghist_content}</wrapper>')
                    bioghist_elements = list(bioghist_wrapper)
                    
                    if existing_bioghist is not None:
                        for bioghist_elem in bioghist_elements:
                            existing_bioghist.append(bioghist_elem)
                    else:
                        # Create new bioghist wrapper and add the elements
                        new_bioghist = ET.Element(f'{namespace}bioghist')
                        for bioghist_elem in bioghist_elements:
                            for child in bioghist_elem:
                                new_bioghist.append(child)
                        archdesc.insert(insert_index, new_bioghist)
                        
                except ET.ParseError as e:
                    self.log.warning(f'Failed to parse bioghist content: {e}')
            
            result = ET.tostring(root, encoding='unicode', method='xml')
            return result
            
        except ET.ParseError as e:
            self.log.error(f'Failed to parse EAD XML: {e}. Returning original content.')
            return ead

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
        
        # Save the original XML to return if no changes are made
        original_xml = eac_cpf_xml

        try:
            # Parse the XML, handling potential namespace issues
            try:
                root = ET.fromstring(eac_cpf_xml)
            except ET.ParseError:
                # If parsing fails, it might be due to undeclared namespaces
                # Try to fix by adding namespace declarations
                if 'xlink:' in eac_cpf_xml and 'xmlns:xlink' not in eac_cpf_xml:
                    # Add xlink namespace declaration to root element
                    eac_cpf_xml = eac_cpf_xml.replace('<eac-cpf>', '<eac-cpf xmlns:xlink="http://www.w3.org/1999/xlink">', 1)
                root = ET.fromstring(eac_cpf_xml)
            
            # Track if any changes were made
            changes_made = False
            
            # Find all resourceRelation elements with resourceRelationType="creatorOf"
            for resource_relation in root.iter('resourceRelation'):
                if resource_relation.get('resourceRelationType') != 'creatorOf':
                    continue
                
                # Check if descriptiveNote with ead_id pattern already exists
                has_ead_id_note = False
                for desc_note in resource_relation.findall('descriptiveNote'):
                    for p in desc_note.findall('p'):
                        if p.text and p.text.startswith('ead_id:'):
                            has_ead_id_note = True
                            break
                    if has_ead_id_note:
                        break
                
                if has_ead_id_note:
                    # Already has our descriptiveNote, skip
                    continue
                
                # Extract href attribute - try multiple variations
                href = None
                # Try with xlink namespace
                for attr_key in resource_relation.attrib:
                    if 'href' in attr_key:
                        href = resource_relation.attrib[attr_key]
                        break
                
                if not href:
                    continue
                
                # Only process resource URLs (skip digital_objects, etc.)
                # Pattern: repositories/{number}/resources/{number}
                uri_match = re.search(r'/repositories/(\d+)/resources/(\d+)', href)
                if not uri_match:
                    # Not a resource URL (likely digital_object or other type) - skip silently
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
                        continue
                    
                    resource = response.json()
                    ead_id = resource.get('ead_id')
                    if not ead_id:
                        self.log.warning(
                            f'{indent}Resource /repositories/{res_repo_id}/resources/{res_resource_id} '
                            'has no ead_id. Skipping collection link.')
                        continue
                    
                    # Create descriptiveNote element with ead_id
                    descriptive_note = ET.Element('descriptiveNote')
                    p = ET.SubElement(descriptive_note, 'p')
                    p.text = f'ead_id:{ead_id}'
                    
                    # Append to resourceRelation
                    resource_relation.append(descriptive_note)
                    changes_made = True
                    
                except Exception as e:
                    self.log.warning(f'{indent}Could not fetch resource for {href}: {e}. Skipping collection link.')
                    continue
            
            # Only convert back to string if changes were made
            if changes_made:
                result = ET.tostring(root, encoding='unicode', method='xml')
                return result
            else:
                # Return original XML (not the potentially modified version with namespace)
                return original_xml
            
        except ET.ParseError as e:
            self.log.error(f'{indent}Failed to parse EAC-CPF XML: {e}. Returning original content.')
            return original_xml

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
