"""
Service for exporting ArchivesSpace digital object metadata as MODS.

ArchivesSpace's EAD export reduces a digital object to a <dao> link. Arcuit
reads the rest of its metadata (dates, names, subjects, notes, conditions
governing use, file versions) from a per-collection MODS 3.8 sidecar,
<xml dir>/digital_objects/<ead_id>.mods.xml, written next to the EAD. The
contract is arcuit's example_docs/xml/digital_objects/UA.99.1.1.mods.xml.

Handles:
- Finding the published digital objects linked to a resource or to any of
  the archival objects in its (published) EAD
- Building the <modsCollection> sidecar for them
- Finding the resources linked to a set of digital objects, so collections
  can be re-exported when their digital objects change
"""

import html
import logging
import re
from typing import Dict, Iterable, List, Optional, Set, Tuple

from lxml import etree

from .digital_object_metadata import (
    ENUMERATIONS_PATH, agent_name, bulk_date_expression, date_label,
    load_enumerations, note_paragraphs, resolved_subjects)


MODS_NS = 'http://www.loc.gov/mods/v3'
XSI_NS = 'http://www.w3.org/2001/XMLSchema-instance'
XLINK_NS = 'http://www.w3.org/1999/xlink'
MODS_SCHEMA_LOCATION = f'{MODS_NS} https://www.loc.gov/standards/mods/v3/mods-3-8.xsd'

ARCHIVAL_OBJECT_URI = re.compile(r'^/repositories/\d+/archival_objects/(\d+)$')
RESOURCE_URI = re.compile(r'^/repositories/\d+/resources/(\d+)$')
DIGITAL_OBJECT_URI = re.compile(r'^/repositories/(\d+)/digital_objects/(\d+)$')


def _m(tag):
    return f'{{{MODS_NS}}}{tag}'


class DigitalObjectModsService:
    """Service for building MODS sidecars from ArchivesSpace digital objects."""

    # ArchivesSpace caps id_set lookups at AppConfig[:max_page_size] (250 by default)
    BATCH_SIZE = 100

    # digital_object_digital_object_type -> MODS typeOfResource
    RESOURCE_TYPES = {
        'cartographic': 'cartographic',
        'mixed_materials': 'mixed material',
        'moving_image': 'moving image',
        'notated_music': 'notated music',
        'software_multimedia': 'software, multimedia',
        'sound_recording': 'sound recording',
        'sound_recording_musical': 'sound recording-musical',
        'sound_recording_nonmusical': 'sound recording-nonmusical',
        'still_image': 'still image',
        'text': 'text',
    }

    AGENT_NAME_TYPES = {
        'agent_person': 'personal',
        'agent_corporate_entity': 'corporate',
        'agent_family': 'family',
    }

    # subject term_type -> MODS <subject> child
    TERM_ELEMENTS = {
        'topical': 'topic',
        'cultural_context': 'topic',
        'style_period': 'topic',
        'technique': 'topic',
        'function': 'topic',
        'geographic': 'geographic',
        'temporal': 'temporal',
        'genre_form': 'genre',
        'occupation': 'occupation',
        'uniform_title': 'titleInfo',
    }

    # date label -> MODS originInfo child; creation dates are listed first
    # so they drive the years Arcuit uses for the date facet
    DATE_ELEMENTS = {
        'creation': 'dateCreated',
        'digitized': 'dateCaptured',
        'publication': 'dateIssued',
        'issued': 'dateIssued',
        'broadcast': 'dateIssued',
        'copyright': 'copyrightDate',
        'modified': 'dateModified',
    }

    DATE_QUALIFIERS = ('approximate', 'inferred', 'questionable')

    # note type -> MODS note type (https://www.loc.gov/standards/mods/mods-notes.html)
    NOTE_TYPES = {
        'acqinfo': 'acquisition',
        'altformavail': 'additional physical form',
        'bibliography': 'bibliography',
        'bioghist': 'biographical/historical',
        'custodhist': 'ownership',
        'originalsloc': 'original location',
        'prefercite': 'preferred citation',
    }

    def __init__(self, client, log=None):
        """
        Initialize the digital object MODS service.

        Args:
            client: ASnake client for fetching ArchivesSpace records
            log: Logger instance (optional, creates default if not provided)
        """
        self.client = client
        self.log = log or logging.getLogger(__name__)

        try:
            self.enumerations = load_enumerations()
        except FileNotFoundError:
            self.log.warning(f'File {ENUMERATIONS_PATH} not found. Date labels will not be translated.')
            self.enumerations = {}

    # -- ArchivesSpace lookups ---------------------------------------------

    def fetch_by_ids(self, repo_uri: str, object_type: str, ids: Iterable[int],
                     resolve: Optional[List[str]] = None) -> List[Dict]:
        """
        Fetch records of one type in batches using the listing endpoint's id_set.

        Args:
            repo_uri: Repository URI (e.g., '/repositories/2')
            object_type: 'archival_objects', 'digital_objects', ...
            ids: Record IDs to fetch
            resolve: Optional list of refs to resolve

        Returns:
            list: Records found (missing IDs are silently dropped by ArchivesSpace)
        """
        ids = list(dict.fromkeys(int(i) for i in ids))
        records = []
        for start in range(0, len(ids), self.BATCH_SIZE):
            params = {'id_set': ids[start:start + self.BATCH_SIZE]}
            if resolve:
                params['resolve'] = resolve
            response = self.client.get(f'{repo_uri}/{object_type}', params=params)
            response.raise_for_status()
            records.extend(response.json())
        return records

    @staticmethod
    def archival_object_uris_from_ead(ead) -> List[str]:
        """
        List the archival object URIs in an EAD exported with include_uris=true.

        The EAD is exported without unpublished components, so these are the
        published archival objects of the collection, in document order.

        Args:
            ead: EAD XML (str or bytes)

        Returns:
            list: Archival object URIs from <unitid type="aspace_uri">
        """
        if isinstance(ead, str):
            ead = ead.encode('utf-8')
        parser = etree.XMLParser(huge_tree=True, resolve_entities=False, no_network=True)
        root = etree.fromstring(ead, parser)
        uris = []
        for unitid in root.iter('{*}unitid'):
            if unitid.get('type') == 'aspace_uri':
                uri = (unitid.text or '').strip()
                if ARCHIVAL_OBJECT_URI.match(uri):
                    uris.append(uri)
        return list(dict.fromkeys(uris))

    def get_published_digital_objects(self, repo_uri: str, resource: Dict,
                                      archival_object_uris: List[str]) -> List[Tuple[Dict, List[str]]]:
        """
        Find the published digital objects of a collection.

        Digital objects are found from fresh archival object JSON rather than
        from the EAD's <dao> elements: ArchivesSpace builds the EAD from its
        Solr index whenever an archival object's lock_version is unchanged,
        and digital object changes don't change it, so the EAD can still list
        a digital object that has been deleted or unpublished.

        Args:
            repo_uri: Repository URI
            resource: Resource JSON (its instances link resource-level digital objects)
            archival_object_uris: Published archival object URIs in the EAD

        Returns:
            list: (digital object JSON, archival object host URIs) pairs in
                  EAD order. Hosts are limited to the archival objects in the
                  EAD; an empty list means the digital object belongs to the
                  collection itself.
        """
        hosts: Dict[str, List[str]] = {}

        ao_ids = [int(ARCHIVAL_OBJECT_URI.match(uri).group(1)) for uri in archival_object_uris]
        archival_objects = {ao['uri']: ao for ao in self.fetch_by_ids(repo_uri, 'archival_objects', ao_ids)}
        for ao_uri in archival_object_uris:
            ao = archival_objects.get(ao_uri)
            if not ao:
                continue
            for do_uri in self._instance_digital_object_uris(ao):
                ao_hosts = hosts.setdefault(do_uri, [])
                if ao_uri not in ao_hosts:
                    ao_hosts.append(ao_uri)

        for do_uri in self._instance_digital_object_uris(resource):
            hosts.setdefault(do_uri, [])

        if not hosts:
            return []

        do_ids = [int(DIGITAL_OBJECT_URI.match(uri).group(2)) for uri in hosts if DIGITAL_OBJECT_URI.match(uri)]
        digital_objects = {
            do['uri']: do
            for do in self.fetch_by_ids(repo_uri, 'digital_objects', do_ids, resolve=['linked_agents', 'subjects'])
        }

        published = []
        for do_uri, ao_hosts in hosts.items():
            digital_object = digital_objects.get(do_uri)
            if digital_object and self.is_published(digital_object):
                published.append((digital_object, ao_hosts))
        return published

    def get_linked_resource_ids(self, repo_uri: str, digital_objects: List[Dict]) -> Set[int]:
        """
        Find the resources that a set of digital objects are linked to,
        directly or through their archival objects.

        Args:
            repo_uri: Repository URI
            digital_objects: Digital object JSON records

        Returns:
            set: Resource IDs
        """
        resource_ids = set()
        ao_ids = set()
        for digital_object in digital_objects:
            for instance in digital_object.get('linked_instances', []):
                ref = instance.get('ref', '')
                resource_match = RESOURCE_URI.match(ref)
                ao_match = ARCHIVAL_OBJECT_URI.match(ref)
                if resource_match:
                    resource_ids.add(int(resource_match.group(1)))
                elif ao_match:
                    ao_ids.add(int(ao_match.group(1)))

        for ao in self.fetch_by_ids(repo_uri, 'archival_objects', sorted(ao_ids)):
            resource_match = RESOURCE_URI.match(ao.get('resource', {}).get('ref', ''))
            if resource_match:
                resource_ids.add(int(resource_match.group(1)))
        return resource_ids

    @staticmethod
    def is_published(record: Dict) -> bool:
        return record.get('publish') is True and not record.get('suppressed', False)

    @staticmethod
    def _instance_digital_object_uris(record: Dict) -> List[str]:
        uris = []
        for instance in record.get('instances', []):
            ref = (instance.get('digital_object') or {}).get('ref')
            if ref and ref not in uris:
                uris.append(ref)
        return uris

    # -- MODS --------------------------------------------------------------

    def build_mods_collection(self, digital_objects: List[Tuple[Dict, List[str]]],
                              resource_uri: str) -> Optional[bytes]:
        """
        Build the MODS sidecar for a collection.

        Args:
            digital_objects: (digital object JSON, archival object host URIs) pairs
            resource_uri: URI of the collection's resource

        Returns:
            bytes: UTF-8 <modsCollection> document, or None if there are no
                   digital objects
        """
        if not digital_objects:
            return None

        root = etree.Element(_m('modsCollection'), nsmap={None: MODS_NS, 'xsi': XSI_NS})
        root.set(f'{{{XSI_NS}}}schemaLocation', MODS_SCHEMA_LOCATION)
        for digital_object, ao_hosts in digital_objects:
            root.append(self.build_mods(digital_object, ao_hosts, resource_uri))

        return etree.tostring(root, xml_declaration=True, encoding='UTF-8', pretty_print=True)

    def build_mods(self, digital_object: Dict, ao_hosts: List[str], resource_uri: str):
        """
        Build one <mods> record for a published digital object.

        Unpublished notes, file versions and agents are left out, matching
        what the ArchivesSpace public interface shows.

        Args:
            digital_object: Digital object JSON with linked_agents and subjects resolved
            ao_hosts: Archival object URIs the digital object is attached to in this EAD
            resource_uri: URI of the collection's resource

        Returns:
            lxml.etree._Element: <mods version="3.8">
        """
        mods = etree.Element(_m('mods'), version='3.8')
        notes = [note for note in digital_object.get('notes', []) if note.get('publish') is True]

        title = self._plain_text(digital_object.get('title'))
        if title:
            self._sub(self._sub(mods, 'titleInfo'), 'title', title)

        for linked_agent in digital_object.get('linked_agents', []):
            if linked_agent.get('role') in ('creator', 'source'):
                name = self._agent_name(mods, linked_agent)
                if name is not None:
                    role = self._sub(name, 'role')
                    self._sub(role, 'roleTerm', linked_agent['role'], type='text')
                    relator = linked_agent.get('relator')
                    if relator:
                        attrs = {'type': 'code'}
                        if re.fullmatch(r'[a-z]{3}', relator):
                            attrs['authority'] = 'marcrelator'
                        self._sub(role, 'roleTerm', relator, **attrs)

        resource_type = digital_object.get('digital_object_type')
        if resource_type:
            self._sub(mods, 'typeOfResource',
                      self.RESOURCE_TYPES.get(resource_type, resource_type.replace('_', ' ')))

        subjects = resolved_subjects(digital_object)
        for subject in subjects:
            terms = subject.get('terms', [])
            if terms and all(t.get('term_type') == 'genre_form' for t in terms):
                self._sub(mods, 'genre', ' -- '.join(t['term'] for t in terms),
                          **self._authority_attrs(subject))

        self._add_origin_info(mods, digital_object.get('dates', []))
        self._add_language(mods, digital_object.get('lang_materials', []))
        self._add_physical_description(mods, digital_object.get('extents', []), notes)

        for note in notes:
            if note.get('type') == 'summary':
                self._sub(mods, 'abstract', self._note_text(note))

        for subject in subjects:
            terms = subject.get('terms', [])
            if not terms or all(t.get('term_type') == 'genre_form' for t in terms):
                continue
            element = self._sub(mods, 'subject', **self._authority_attrs(subject))
            self._add_subject_terms(element, terms)

        for linked_agent in digital_object.get('linked_agents', []):
            if linked_agent.get('role') == 'subject':
                element = etree.Element(_m('subject'))
                if self._agent_name(element, linked_agent) is not None:
                    self._add_subject_terms(element, linked_agent.get('terms', []))
                    mods.append(element)

        for note in notes:
            if note.get('type') == 'userestrict':
                self._sub(mods, 'accessCondition', self._note_text(note), type='use and reproduction')
            elif note.get('type') == 'accessrestrict':
                self._sub(mods, 'accessCondition', self._note_text(note), type='restriction on access')

        for note in notes:
            note_type = note.get('type')
            if note.get('jsonmodel_type') == 'note_bibliography':
                note_type = 'bibliography'
            elif note_type in ('summary', 'userestrict', 'accessrestrict', 'extent', 'physdesc', 'dimensions'):
                continue
            attrs = {}
            if note_type in self.NOTE_TYPES:
                attrs['type'] = self.NOTE_TYPES[note_type]
            if note.get('label'):
                attrs['displayLabel'] = note['label']
            self._sub(mods, 'note', self._note_text(note), **attrs)

        for lang_material in digital_object.get('lang_materials', []):
            for note in lang_material.get('notes', []):
                if note.get('publish') is True:
                    self._sub(mods, 'note', self._note_text(note), type='language')

        self._add_locations(mods, digital_object.get('file_versions', []))

        if digital_object.get('digital_object_id'):
            self._sub(mods, 'identifier', digital_object['digital_object_id'], type='local')

        for ao_uri in ao_hosts:
            host = self._sub(mods, 'relatedItem', type='host', displayLabel='archival_object')
            self._sub(host, 'identifier', ao_uri, type='uri')
        host = self._sub(mods, 'relatedItem', type='host', displayLabel='resource')
        self._sub(host, 'identifier', resource_uri, type='uri')

        record_info = self._sub(mods, 'recordInfo')
        self._sub(record_info, 'recordIdentifier', digital_object['uri'], source='ArchivesSpace')
        if digital_object.get('system_mtime'):
            self._sub(record_info, 'recordChangeDate', digital_object['system_mtime'], encoding='iso8601')

        return mods

    def _agent_name(self, parent, linked_agent):
        agent = linked_agent.get('_resolved')
        if not agent or agent.get('publish') is not True:
            return None
        name_part = self._plain_text(agent_name(agent))
        if not name_part:
            return None
        attrs = {}
        name_type = self.AGENT_NAME_TYPES.get(agent.get('jsonmodel_type'))
        if name_type:
            attrs['type'] = name_type
        name = self._sub(parent, 'name', **attrs)
        self._sub(name, 'namePart', name_part)
        return name

    def _add_subject_terms(self, subject, terms):
        for term in terms:
            value = self._plain_text(term.get('term'))
            if not value:
                continue
            element = self.TERM_ELEMENTS.get(term.get('term_type'), 'topic')
            if element == 'titleInfo':
                self._sub(self._sub(subject, 'titleInfo'), 'title', value)
            else:
                self._sub(subject, element, value)

    def _add_origin_info(self, mods, dates):
        if not dates:
            return
        origin_info = etree.Element(_m('originInfo'))
        has_key_date = False
        ordered = sorted(dates, key=lambda d: (d.get('label') or 'creation') != 'creation')
        for date in ordered:
            label = date.get('label') or 'creation'
            element = self.DATE_ELEMENTS.get(label, 'dateOther')
            label_attrs = {'type': label} if element == 'dateOther' else {}

            display = self._display_date(date)
            if display:
                self._sub(origin_info, element, display, **label_attrs)

            begin = (date.get('begin') or '').strip()
            end = (date.get('end') or '').strip()
            if not begin:
                continue
            qualifier = date.get('certainty')
            encoded_attrs = {'encoding': 'w3cdtf'}
            if date.get('date_type') == 'single' or not end or end == begin:
                points = [(None, begin)]
            else:
                points = [('start', begin), ('end', end)]
            for point, value in points:
                attrs = dict(encoded_attrs)
                if point:
                    attrs['point'] = point
                if not has_key_date:
                    attrs['keyDate'] = 'yes'
                    has_key_date = True
                if qualifier in self.DATE_QUALIFIERS:
                    attrs['qualifier'] = qualifier
                attrs.update(label_attrs)
                self._sub(origin_info, element, value, **attrs)

        if len(origin_info):
            mods.append(origin_info)

    def _display_date(self, date):
        """
        Free-text date from the date expression, labelled like
        OmekaService._parse_date. With no expression, Arcuit builds the
        display date from the encoded years, so begin and end aren't used.
        """
        expression = self._plain_text(date.get('expression'))
        if not expression:
            return ''
        expression = bulk_date_expression(date, expression, self.enumerations)
        label = date_label(date, self.enumerations)
        return f'{label}: {expression}' if label else expression

    def _add_language(self, mods, lang_materials):
        for lang_material in lang_materials:
            language_and_script = lang_material.get('language_and_script') or {}
            if language_and_script.get('language'):
                language = self._sub(mods, 'language')
                self._sub(language, 'languageTerm', language_and_script['language'],
                          type='code', authority='iso639-2b')
                if language_and_script.get('script'):
                    self._sub(language, 'scriptTerm', language_and_script['script'],
                              type='code', authority='iso15924')

    def _add_physical_description(self, mods, extents, notes):
        physical_description = etree.Element(_m('physicalDescription'))
        for extent in extents:
            value = ' '.join(filter(None, [
                str(extent.get('number') or '').strip(),
                (extent.get('extent_type') or '').replace('_', ' ').strip(),
            ]))
            details = '; '.join(filter(None, [
                (extent.get(k) or '').strip()
                for k in ('container_summary', 'physical_details', 'dimensions')
            ]))
            if details:
                value = f'{value} ({details})' if value else details
            if value:
                self._sub(physical_description, 'extent', value)
        for note in notes:
            if note.get('type') == 'extent':
                self._sub(physical_description, 'extent', self._note_text(note))
        for note in notes:
            if note.get('type') in ('physdesc', 'dimensions'):
                attrs = {'type': 'dimensions'} if note['type'] == 'dimensions' else {}
                self._sub(physical_description, 'note', self._note_text(note), **attrs)
        if len(physical_description):
            mods.append(physical_description)

    def _add_locations(self, mods, file_versions):
        published = [
            fv for fv in file_versions
            if fv.get('publish') is True and (fv.get('file_uri') or '').strip()
        ]
        others = [fv for fv in published if not self._is_thumbnail(fv)]
        primary = next(
            (fv for fv in others if fv.get('is_display_link') or fv.get('is_representative')),
            others[0] if others else None)

        for file_version in published:
            attrs = {}
            if file_version is primary:
                attrs['usage'] = 'primary display'
            elif self._is_thumbnail(file_version):
                # Arcuit skips previews when listing a digital object's files
                attrs['access'] = 'preview'
            caption = self._plain_text(file_version.get('caption'))
            if caption:
                attrs['displayLabel'] = caption
            location = self._sub(mods, 'location')
            self._sub(location, 'url', file_version['file_uri'].strip(), **attrs)

    @staticmethod
    def _is_thumbnail(file_version):
        return (file_version.get('is_display_thumbnail') is True
                or file_version.get('xlink_show_attribute') == 'embed'
                or file_version.get('use_statement') == 'image-thumbnail')

    @staticmethod
    def _authority_attrs(subject):
        attrs = {}
        if subject.get('source'):
            attrs['authority'] = subject['source']
        authority_id = subject.get('authority_id') or ''
        if authority_id.startswith(('http://', 'https://')):
            attrs['valueURI'] = authority_id
        return attrs

    def _note_text(self, note):
        """Plain text of a note's content (and bibliography items)."""
        paragraphs = [self._plain_text(p) for p in note_paragraphs(note)]
        return '\n\n'.join(p for p in paragraphs if p)

    @staticmethod
    def _plain_text(value) -> str:
        """
        Strip EAD markup (<emph>, <title>, <extref>, ...) from ArchivesSpace
        text. MODS text elements can't hold child elements, so markup is
        reduced to its text; lxml escapes any remaining special characters
        when the sidecar is serialized.
        """
        if not value:
            return ''
        value = str(value)
        try:
            fragment = etree.fromstring(f'<x xmlns:xlink="{XLINK_NS}">{value}</x>')
            text = ''.join(fragment.itertext())
        except etree.XMLSyntaxError:
            text = html.unescape(re.sub(r'<[^>]+>', '', value))
        return text.strip()

    @staticmethod
    def _sub(parent, tag, text=None, **attrs):
        element = etree.SubElement(parent, _m(tag))
        for key, value in attrs.items():
            element.set(key, value)
        if text is not None:
            element.text = text
        return element
