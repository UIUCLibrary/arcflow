"""
Tests for DigitalObjectModsService.
"""

import unittest
from unittest.mock import Mock
from lxml import etree
from arcflow.services.digital_object_mods_service import DigitalObjectModsService


NS = {'m': 'http://www.loc.gov/mods/v3'}
RESOURCE_URI = '/repositories/2/resources/1'


def response(payload):
    mock = Mock()
    mock.json.return_value = payload
    return mock


def published_agent(jsonmodel_type, title, publish=True):
    return {'jsonmodel_type': jsonmodel_type, 'title': title, 'publish': publish}


def rich_digital_object():
    return {
        'uri': '/repositories/2/digital_objects/5',
        'digital_object_id': 'UA.99.1.1.DO.001',
        'title': 'Campus views, <emph render="italic">1925-1935</emph>',
        'publish': True,
        'suppressed': False,
        'system_mtime': '2026-03-03T12:00:00Z',
        'digital_object_type': 'still_image',
        'linked_agents': [
            {'role': 'creator', '_resolved': published_agent('agent_corporate_entity', 'Office of the Registrar')},
            {'role': 'creator', 'relator': 'pht', '_resolved': published_agent('agent_person', 'Example, Photographer')},
            {'role': 'creator', '_resolved': published_agent('agent_person', 'Hidden, Agent', publish=False)},
            {'role': 'subject', 'terms': [{'term': 'Photographs', 'term_type': 'genre_form'}],
             '_resolved': published_agent('agent_corporate_entity', 'Example Hall (Urbana, Ill.)')},
        ],
        'subjects': [
            {'_resolved': {'source': 'aat', 'terms': [{'term': 'glass plate negatives', 'term_type': 'genre_form'}]}},
            {'_resolved': {'source': 'lcsh', 'authority_id': 'http://id.loc.gov/authorities/subjects/sh1',
                           'terms': [{'term': 'Universities and colleges', 'term_type': 'topical'},
                                     {'term': 'Illinois', 'term_type': 'geographic'}]}},
        ],
        'dates': [
            {'label': 'digitized', 'date_type': 'single', 'begin': '2010', 'expression': '2010'},
            {'label': 'creation', 'date_type': 'inclusive', 'begin': '1925', 'end': '1935',
             'expression': '1925-1935', 'certainty': 'approximate'},
        ],
        'extents': [{'number': '48', 'extent_type': 'glass_plate_negatives', 'dimensions': '4 x 5 in.'}],
        'lang_materials': [
            {'language_and_script': {'language': 'eng', 'script': 'Latn'}},
            {'notes': [{'jsonmodel_type': 'note_langmaterial', 'publish': True, 'content': ['In English.']}]},
        ],
        'notes': [
            {'jsonmodel_type': 'note_digital_object', 'type': 'summary', 'publish': True,
             'content': ['Views of the Main Quadrangle &amp; <title>Altgeld Hall</title>.']},
            {'jsonmodel_type': 'note_digital_object', 'type': 'physdesc', 'publish': True,
             'content': ['Several plates are cracked.']},
            {'jsonmodel_type': 'note_digital_object', 'type': 'userestrict', 'publish': True,
             'content': ['Research use only.']},
            {'jsonmodel_type': 'note_digital_object', 'type': 'accessrestrict', 'publish': True,
             'content': ['Originals restricted.']},
            {'jsonmodel_type': 'note_digital_object', 'type': 'custodhist', 'label': 'Provenance', 'publish': True,
             'content': ['First paragraph.', 'Second paragraph.']},
            {'jsonmodel_type': 'note_digital_object', 'type': 'note', 'publish': False,
             'content': ['STAFF ONLY: do not show']},
            {'jsonmodel_type': 'note_digital_object', 'type': 'note', 'content': ['No publish flag']},
            {'jsonmodel_type': 'note_bibliography', 'publish': True, 'content': ['Cited in:'],
             'items': ['Example, A. Campus history (1950).']},
        ],
        'file_versions': [
            {'file_uri': 'https://example.edu/thumb.jpg', 'publish': True, 'xlink_show_attribute': 'embed'},
            {'file_uri': 'https://example.edu/item', 'publish': True, 'caption': 'View in the Digital Library'},
            {'file_uri': 'https://example.edu/secret.tif', 'publish': False},
            {'file_uri': 'https://example.edu/original.tif', 'publish': True, 'is_representative': True,
             'caption': 'Download (TIFF)'},
            {'file_uri': '  ', 'publish': True},
        ],
    }


class TestDigitalObjectModsService(unittest.TestCase):
    """Test cases for DigitalObjectModsService."""

    def setUp(self):
        self.mock_client = Mock()
        self.mock_log = Mock()
        self.service = DigitalObjectModsService(client=self.mock_client, log=self.mock_log)

    def build(self, digital_object=None, ao_hosts=None):
        return self.service.build_mods(
            digital_object or rich_digital_object(),
            ['/repositories/2/archival_objects/3'] if ao_hosts is None else ao_hosts,
            RESOURCE_URI)

    def texts(self, element, xpath):
        return [e.text for e in element.xpath(xpath, namespaces=NS)]

    def test_title_is_plain_text(self):
        mods = self.build()
        self.assertEqual(mods.get('version'), '3.8')
        self.assertEqual(self.texts(mods, 'm:titleInfo/m:title'), ['Campus views, 1925-1935'])

    def test_names_skip_unpublished_agents_and_mark_creators(self):
        mods = self.build()
        names = mods.xpath('m:name', namespaces=NS)
        self.assertEqual([n.get('type') for n in names], ['corporate', 'personal'])
        self.assertEqual(self.texts(names[1], 'm:namePart'), ['Example, Photographer'])
        self.assertEqual(self.texts(names[1], 'm:role/m:roleTerm'), ['creator', 'pht'])
        relator = names[1].xpath('m:role/m:roleTerm[@type="code"]', namespaces=NS)[0]
        self.assertEqual(relator.get('authority'), 'marcrelator')
        self.assertNotIn('Hidden, Agent', etree.tostring(mods, encoding='unicode'))

    def test_type_and_genre(self):
        mods = self.build()
        self.assertEqual(self.texts(mods, 'm:typeOfResource'), ['still image'])
        genre = mods.xpath('m:genre', namespaces=NS)[0]
        self.assertEqual((genre.text, genre.get('authority')), ('glass plate negatives', 'aat'))

    def test_type_of_resource_mapping(self):
        do = rich_digital_object()
        do['digital_object_type'] = 'software_multimedia'
        self.assertEqual(self.texts(self.build(do), 'm:typeOfResource'), ['software, multimedia'])

    def test_dates_list_creation_first_with_encoded_years(self):
        origin_info = self.build().xpath('m:originInfo', namespaces=NS)[0]
        children = [(etree.QName(e).localname, e.text, dict(e.attrib)) for e in origin_info]
        self.assertEqual(children, [
            ('dateCreated', '1925-1935', {}),
            ('dateCreated', '1925', {'encoding': 'w3cdtf', 'point': 'start', 'keyDate': 'yes', 'qualifier': 'approximate'}),
            ('dateCreated', '1935', {'encoding': 'w3cdtf', 'point': 'end', 'qualifier': 'approximate'}),
            ('dateCaptured', 'Digitized: 2010', {}),
            ('dateCaptured', '2010', {'encoding': 'w3cdtf'}),
        ])

    def test_date_without_expression_has_only_encoded_years(self):
        do = rich_digital_object()
        do['dates'] = [{'label': 'creation', 'date_type': 'inclusive', 'begin': '1928', 'end': '1931'},
                       {'label': 'other', 'date_type': 'single', 'begin': '1942-05-01', 'expression': 'May 1942'}]
        origin_info = self.build(do).xpath('m:originInfo', namespaces=NS)[0]
        self.assertEqual(self.texts(origin_info, 'm:dateCreated[not(@encoding)]'), [])
        self.assertEqual(self.texts(origin_info, 'm:dateCreated[@point="start"][@keyDate="yes"]'), ['1928'])
        self.assertEqual(self.texts(origin_info, 'm:dateCreated[@point="end"]'), ['1931'])
        self.assertEqual(self.texts(origin_info, 'm:dateOther[@type="other"]'), ['Other: May 1942', '1942-05-01'])

    def test_physical_description(self):
        physical_description = self.build().xpath('m:physicalDescription', namespaces=NS)[0]
        self.assertEqual(self.texts(physical_description, 'm:extent'), ['48 glass plate negatives (4 x 5 in.)'])
        self.assertEqual(self.texts(physical_description, 'm:note'), ['Several plates are cracked.'])

    def test_abstract_subjects_and_access_conditions(self):
        mods = self.build()
        self.assertEqual(self.texts(mods, 'm:abstract'), ['Views of the Main Quadrangle & Altgeld Hall.'])
        subjects = mods.xpath('m:subject', namespaces=NS)
        self.assertEqual(subjects[0].get('authority'), 'lcsh')
        self.assertEqual(subjects[0].get('valueURI'), 'http://id.loc.gov/authorities/subjects/sh1')
        self.assertEqual([(etree.QName(e).localname, e.text) for e in subjects[0]],
                         [('topic', 'Universities and colleges'), ('geographic', 'Illinois')])
        self.assertEqual(self.texts(subjects[1], 'm:name[@type="corporate"]/m:namePart'), ['Example Hall (Urbana, Ill.)'])
        self.assertEqual(self.texts(subjects[1], 'm:genre'), ['Photographs'])
        self.assertEqual(self.texts(mods, 'm:accessCondition[@type="use and reproduction"]'), ['Research use only.'])
        self.assertEqual(self.texts(mods, 'm:accessCondition[@type="restriction on access"]'), ['Originals restricted.'])

    def test_notes_skip_unpublished(self):
        mods = self.build()
        notes = mods.xpath('m:note', namespaces=NS)
        self.assertEqual([(n.get('type'), n.get('displayLabel'), n.text) for n in notes], [
            ('ownership', 'Provenance', 'First paragraph.\n\nSecond paragraph.'),
            ('bibliography', None, 'Cited in:\n\nExample, A. Campus history (1950).'),
            ('language', None, 'In English.'),
        ])
        self.assertNotIn('STAFF ONLY', etree.tostring(mods, encoding='unicode'))
        self.assertNotIn('No publish flag', etree.tostring(mods, encoding='unicode'))

    def test_locations_are_published_file_versions(self):
        urls = self.build().xpath('m:location/m:url', namespaces=NS)
        self.assertEqual([(u.text, dict(u.attrib)) for u in urls], [
            ('https://example.edu/thumb.jpg', {'access': 'preview'}),
            ('https://example.edu/item', {'displayLabel': 'View in the Digital Library'}),
            ('https://example.edu/original.tif', {'usage': 'primary display', 'displayLabel': 'Download (TIFF)'}),
        ])

    def test_primary_display_defaults_to_first_non_thumbnail(self):
        do = rich_digital_object()
        do['file_versions'][3]['is_representative'] = False
        urls = self.build(do).xpath('m:location/m:url[@usage="primary display"]', namespaces=NS)
        self.assertEqual([u.text for u in urls], ['https://example.edu/item'])

    def test_identifiers_hosts_and_record_info(self):
        mods = self.build()
        self.assertEqual(self.texts(mods, 'm:identifier[@type="local"]'), ['UA.99.1.1.DO.001'])
        hosts = mods.xpath('m:relatedItem[@type="host"]', namespaces=NS)
        self.assertEqual([(h.get('displayLabel'), self.texts(h, 'm:identifier[@type="uri"]')) for h in hosts], [
            ('archival_object', ['/repositories/2/archival_objects/3']),
            ('resource', [RESOURCE_URI]),
        ])
        self.assertEqual(self.texts(mods, 'm:recordInfo/m:recordIdentifier[@source="ArchivesSpace"]'),
                         ['/repositories/2/digital_objects/5'])
        self.assertEqual(self.texts(mods, 'm:recordInfo/m:recordChangeDate[@encoding="iso8601"]'),
                         ['2026-03-03T12:00:00Z'])

    def test_element_order_matches_contract(self):
        order = [etree.QName(e).localname for e in self.build()]
        expected = ['titleInfo', 'name', 'typeOfResource', 'genre', 'originInfo', 'language',
                    'physicalDescription', 'abstract', 'subject', 'accessCondition', 'note',
                    'location', 'identifier', 'relatedItem', 'recordInfo']
        self.assertEqual(list(dict.fromkeys(order)), expected)

    def test_minimal_digital_object(self):
        mods = self.build({'uri': '/repositories/2/digital_objects/9', 'title': 'Minimal', 'publish': True},
                          ao_hosts=[])
        self.assertEqual([etree.QName(e).localname for e in mods],
                         ['titleInfo', 'relatedItem', 'recordInfo'])

    def test_build_mods_collection(self):
        self.assertIsNone(self.service.build_mods_collection([], RESOURCE_URI))

        xml = self.service.build_mods_collection([(rich_digital_object(), [])], RESOURCE_URI)
        self.assertTrue(xml.startswith(b"<?xml version='1.0' encoding='UTF-8'?>"))
        root = etree.fromstring(xml)
        self.assertEqual(root.tag, '{http://www.loc.gov/mods/v3}modsCollection')
        self.assertEqual(
            root.get('{http://www.w3.org/2001/XMLSchema-instance}schemaLocation'),
            'http://www.loc.gov/mods/v3 https://www.loc.gov/standards/mods/v3/mods-3-8.xsd')
        self.assertEqual(len(root.xpath('m:mods[@version="3.8"]', namespaces=NS)), 1)

    def test_plain_text(self):
        plain = DigitalObjectModsService._plain_text
        self.assertEqual(plain('<emph render="bold">Bold</emph> text'), 'Bold text')
        self.assertEqual(plain('<extref xlink:href="https://x.org">link</extref>'), 'link')
        self.assertEqual(plain('Smith & Sons <unclosed'), 'Smith & Sons <unclosed')
        self.assertEqual(plain('Caf&eacute; <emph>A</emph>'), 'Café A')
        self.assertEqual(plain(None), '')

    def test_archival_object_uris_from_ead(self):
        ead = b'''<?xml version="1.0" encoding="UTF-8"?>
        <ead xmlns="urn:isbn:1-931666-22-9"><archdesc level="collection"><did>
          <unitid type="aspace_uri">/repositories/2/resources/1</unitid></did>
          <dsc><c id="aspace_a"><did><unitid type="aspace_uri">/repositories/2/archival_objects/7</unitid></did>
            <c id="aspace_b"><did><unitid>local</unitid><unitid type="aspace_uri">/repositories/2/archival_objects/3</unitid></did></c>
          </c></dsc></archdesc></ead>'''
        self.assertEqual(DigitalObjectModsService.archival_object_uris_from_ead(ead),
                         ['/repositories/2/archival_objects/7', '/repositories/2/archival_objects/3'])

    def test_get_published_digital_objects(self):
        archival_objects = [
            {'uri': '/repositories/2/archival_objects/7', 'instances': [
                {'instance_type': 'digital_object', 'digital_object': {'ref': '/repositories/2/digital_objects/5'}},
                {'instance_type': 'digital_object', 'digital_object': {'ref': '/repositories/2/digital_objects/6'}},
            ]},
            {'uri': '/repositories/2/archival_objects/3', 'instances': [
                {'instance_type': 'mixed_materials', 'sub_container': {}},
                {'instance_type': 'digital_object', 'digital_object': {'ref': '/repositories/2/digital_objects/5'}},
                {'instance_type': 'digital_object', 'digital_object': {'ref': '/repositories/2/digital_objects/7'}},
            ]},
        ]
        digital_objects = [
            {'uri': '/repositories/2/digital_objects/5', 'publish': True, 'suppressed': False},
            {'uri': '/repositories/2/digital_objects/6', 'publish': False, 'suppressed': False},
            {'uri': '/repositories/2/digital_objects/7', 'publish': True, 'suppressed': True},
            {'uri': '/repositories/2/digital_objects/8', 'publish': True},
        ]
        self.mock_client.get.side_effect = [response(archival_objects), response(digital_objects)]
        resource = {'uri': RESOURCE_URI, 'instances': [
            {'instance_type': 'digital_object', 'digital_object': {'ref': '/repositories/2/digital_objects/8'}}]}

        result = self.service.get_published_digital_objects(
            '/repositories/2', resource,
            ['/repositories/2/archival_objects/7', '/repositories/2/archival_objects/3'])

        self.assertEqual([(do['uri'], hosts) for do, hosts in result], [
            ('/repositories/2/digital_objects/5',
             ['/repositories/2/archival_objects/7', '/repositories/2/archival_objects/3']),
            ('/repositories/2/digital_objects/8', []),
        ])
        ao_call, do_call = self.mock_client.get.call_args_list
        self.assertEqual(ao_call.args[0], '/repositories/2/archival_objects')
        self.assertEqual(ao_call.kwargs['params'], {'id_set': [7, 3]})
        self.assertEqual(do_call.args[0], '/repositories/2/digital_objects')
        self.assertEqual(do_call.kwargs['params'],
                         {'id_set': [5, 6, 7, 8], 'resolve': ['linked_agents', 'subjects']})

    def test_get_published_digital_objects_without_any(self):
        self.mock_client.get.return_value = response([{'uri': '/repositories/2/archival_objects/7', 'instances': []}])
        result = self.service.get_published_digital_objects(
            '/repositories/2', {'instances': []}, ['/repositories/2/archival_objects/7'])
        self.assertEqual(result, [])
        self.assertEqual(self.mock_client.get.call_count, 1)

    def test_fetch_by_ids_batches(self):
        self.service.BATCH_SIZE = 2
        self.mock_client.get.side_effect = [response([{'id': 1}, {'id': 2}]), response([{'id': 3}])]
        records = self.service.fetch_by_ids('/repositories/2', 'archival_objects', [1, 2, 3, 2])
        self.assertEqual(records, [{'id': 1}, {'id': 2}, {'id': 3}])
        self.assertEqual([c.kwargs['params']['id_set'] for c in self.mock_client.get.call_args_list], [[1, 2], [3]])

    def test_get_linked_resource_ids(self):
        self.mock_client.get.return_value = response([
            {'uri': '/repositories/2/archival_objects/7', 'resource': {'ref': '/repositories/2/resources/4'}},
        ])
        digital_objects = [
            {'linked_instances': [{'ref': '/repositories/2/resources/1'},
                                  {'ref': '/repositories/2/archival_objects/7'},
                                  {'ref': '/repositories/2/accessions/9'}]},
            {},
        ]
        self.assertEqual(self.service.get_linked_resource_ids('/repositories/2', digital_objects), {1, 4})
        self.assertEqual(self.mock_client.get.call_args.kwargs['params'], {'id_set': [7]})


if __name__ == '__main__':
    unittest.main()
