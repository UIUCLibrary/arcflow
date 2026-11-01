"""
Characterization tests for the metadata OmekaService sends to Omeka.
"""

import unittest
from unittest.mock import Mock
from arcflow.services.omeka.omeka_service import OmekaService


ARCLIGHT = 'https://arclight.example.edu'


def response(payload):
    mock = Mock()
    mock.json.return_value = payload
    return mock


def make_service():
    client = Mock()
    client.get.return_value = response({
        'publish': True,
        'path_from_root': [
            {'identifier': '15', 'title': 'Student Affairs'},
            {'identifier': '7', 'title': 'Student Organizations'},
        ],
    })
    return OmekaService(
        log=Mock(),
        asnake_client=client,
        omeka={
            'api_url': 'https://omeka.example.edu/api',
            'public_url': 'https://omeka.example.edu',
            'key_identity': 'id',
            'key_credential': 'credential',
        },
        arclight={'public_url': ARCLIGHT},
    )


def rich_digital_object():
    return {
        'uri': '/repositories/2/digital_objects/5',
        'digital_object_id': 'UA.99.1.1.DO.001',
        'title': 'Campus views',
        'publish': True,
        'suppressed': False,
        'repository': {'_resolved': {
            'uri': '/repositories/2', 'name': 'University Archives', 'publish': True}},
        'collection': [{'_resolved': {
            'ead_id': 'UA.99.1.1', 'title': 'Example Collection', 'publish': True,
            'classifications': [{'ref': '/repositories/2/classification_terms/3'}],
        }}],
        'lang_materials': [
            {'language_and_script': {'language': 'eng', 'script': 'Latn'}},
            {'language_and_script': {'language': 'ger'}},
            {'notes': [{'content': ['Mostly English.'], 'publish': False}]},
        ],
        'dates': [
            {'label': 'creation', 'date_type': 'inclusive', 'expression': 'circa 1925-1935',
             'begin': '1925', 'end': '1935'},
            {'label': 'creation', 'date_type': 'inclusive', 'begin': '1925', 'end': '1935'},
            {'label': 'digitized', 'date_type': 'single', 'begin': '2020'},
            {'label': 'creation', 'date_type': 'bulk', 'expression': 'bulk (1930)',
             'begin': '1930', 'end': '1930'},
            {'label': 'creation', 'date_type': 'bulk', 'expression': '1926-1934',
             'begin': '1926', 'end': '1934'},
            {'label': 'other_label', 'date_type': 'single', 'expression': '1950'},
            {'date_type': 'single', 'expression': '1960'},
        ],
        'linked_agents': [
            {'role': 'creator', '_resolved': {'title': 'Office of the Registrar', 'publish': True}},
            {'role': 'creator', '_resolved': {'title': 'Hidden, Agent', 'publish': False}},
            {'role': 'source', '_resolved': {'title': 'Donor, A.', 'publish': True}},
            {'role': 'subject', '_resolved': {'title': 'Example Hall', 'publish': True}},
            {'role': 'creator', 'ref': '/agents/people/9'},
        ],
        'subjects': [
            {'_resolved': {'terms': [
                {'term': 'Universities and colleges', 'term_type': 'topical'},
                {'term': 'Illinois', 'term_type': 'geographic'},
                {'term': '20th century', 'term_type': 'temporal'},
            ]}},
            {'_resolved': {'terms': [{'term': 'Photographs', 'term_type': 'genre_form'}]}},
            {'ref': '/subjects/9'},
        ],
        'notes': [
            {'type': 'summary', 'publish': True, 'content': [
                'Views of <a href="https://example.edu">campus</a>.', 'Second paragraph.']},
            {'type': 'physdesc', 'publish': False, 'content': ['24 photographs']},
            {'type': 'userestrict', 'publish': True, 'content': ['Copyright retained.']},
            {'type': 'note', 'label': 'Contributor Note', 'publish': True, 'content': ['Jane Doe']},
            {'type': 'note', 'label': 'Contributor', 'publish': True, 'content': ['John Doe']},
            {'type': 'note', 'label': 'General', 'publish': True, 'content': ['Ignored']},
            {'type': 'accessrestrict', 'publish': True, 'content': ['Ignored']},
        ],
    }


class TestPrepareItemData(unittest.TestCase):
    maxDiff = None

    def test_rich_digital_object(self):
        service = make_service()

        item_data = service._prepare_item_data(rich_digital_object())

        service.asnake_client.get.assert_called_once_with('/repositories/2/classification_terms/3')
        record_group = '15 — Student Affairs'
        subgroup = '15.7 — Student Organizations'
        self.assertEqual(item_data, {
            'dcterms:title': [
                {'property_id': 'auto', '@value': 'Campus views', 'type': 'literal'}],
            'dcterms:identifier': [
                {'property_id': 'auto', '@value': '/repositories/2/digital_objects/5',
                 'type': 'literal', 'is_public': False},
                {'property_id': 'auto', '@value': 'UA.99.1.1.DO.001', 'type': 'literal'},
            ],
            '@type': 'o:Item',
            'o:is_public': True,
            'schema:holdingArchive': [{
                'property_id': 'auto', 'o:label': 'University Archives',
                '@id': f'{ARCLIGHT}/repositories/2', 'type': 'uri', 'is_public': True}],
            'dcterms:isPartOf': [
                {'property_id': 'auto', 'o:label': record_group,
                 '@id': f'{ARCLIGHT}/record_groups/{record_group}', 'type': 'uri', 'is_public': True},
                {'property_id': 'auto', 'o:label': subgroup,
                 '@id': f'{ARCLIGHT}/catalog?f[level][]=Collection&f[record_group_ssim][]={record_group}&f[subgroup_ssim][]={subgroup}&group=false',
                 'type': 'uri', 'is_public': True},
                {'property_id': 'auto', 'o:label': 'UA.99.1.1 — Example Collection',
                 '@id': f'{ARCLIGHT}/catalog/UA-99-1-1', 'type': 'uri', 'is_public': True},
            ],
            'dcterms:language': [
                {'property_id': 'auto', '@value': 'English - Latin', 'type': 'literal'},
                {'property_id': 'auto', '@value': 'German', 'type': 'literal'},
                {'property_id': 'auto', '@value': 'Mostly English.', 'type': 'literal', 'is_public': False},
            ],
            'dcterms:date': [
                {'property_id': 'auto', '@value': 'circa 1925-1935', 'type': 'literal'},
                {'property_id': 'auto', '@value': '1925 - 1935', 'type': 'literal'},
                {'property_id': 'auto', '@value': 'Digitized:  2020', 'type': 'literal'},
                {'property_id': 'auto', '@value': 'Majority of material found in (1930)', 'type': 'literal'},
                {'property_id': 'auto', '@value': 'Majority of material found within 1926-1934', 'type': 'literal'},
                {'property_id': 'auto', '@value': 'other_label:  1950', 'type': 'literal'},
                {'property_id': 'auto', '@value': '1960', 'type': 'literal'},
            ],
            'dcterms:creator': [
                {'property_id': 'auto', '@value': 'Office of the Registrar', 'type': 'literal', 'is_public': True},
                {'property_id': 'auto', '@value': 'Hidden, Agent', 'type': 'literal', 'is_public': False},
            ],
            'dcterms:subject': [
                {'property_id': 'auto', '@value': 'Example Hall', 'type': 'literal', 'is_public': True},
                {'property_id': 'auto', '@value': 'Universities and colleges', 'type': 'literal'},
            ],
            'dcterms:spatial': [
                {'property_id': 'auto', '@value': 'Illinois', 'type': 'literal'}],
            'schema:genre': [
                {'property_id': 'auto', '@value': 'Photographs', 'type': 'literal'}],
            'dcterms:description': [{
                'property_id': 'auto',
                '@value': 'Views of <ref href="https://example.edu">campus</ref>.\n\nSecond paragraph.',
                'type': 'ead:xml', 'is_public': True}],
            'dcterms:extent': [
                {'property_id': 'auto', '@value': '24 photographs', 'type': 'ead:xml', 'is_public': False}],
            'dcterms:accessRights': [
                {'property_id': 'auto', '@value': 'Copyright retained.', 'type': 'ead:xml', 'is_public': True}],
            'dcterms:contributor': [
                {'property_id': 'auto', '@value': 'Jane Doe', 'type': 'literal', 'is_public': True},
                {'property_id': 'auto', '@value': 'John Doe', 'type': 'literal', 'is_public': True},
            ],
        })

    def test_minimal_unpublished_digital_object(self):
        item_data = make_service()._prepare_item_data({
            'uri': '/repositories/2/digital_objects/6',
            'digital_object_id': 'DO.002',
            'title': 'Untitled',
            'publish': True,
            'suppressed': True,
        })

        self.assertEqual(item_data, {
            'dcterms:title': [{'property_id': 'auto', '@value': 'Untitled', 'type': 'literal'}],
            'dcterms:identifier': [
                {'property_id': 'auto', '@value': '/repositories/2/digital_objects/6',
                 'type': 'literal', 'is_public': False},
                {'property_id': 'auto', '@value': 'DO.002', 'type': 'literal'},
            ],
            '@type': 'o:Item',
            'o:is_public': False,
        })


class TestIsPublic(unittest.TestCase):

    def test_is_public(self):
        service = make_service()
        self.assertIs(service._is_public({'publish': True}), True)
        self.assertIs(service._is_public({'publish': True, 'suppressed': True}), False)
        self.assertIs(service._is_public({}), False)
        # file versions created from Archon carry its access level as publish
        self.assertEqual(service._is_public({'publish': 1}), 1)


class TestParseDate(unittest.TestCase):

    def test_parse_date(self):
        service = make_service()
        cases = [
            ({'label': 'creation', 'expression': '1925'}, ('', '1925', 'creation')),
            ({'label': 'digitized', 'begin': '2020', 'end': '2021'}, ('Digitized: ', '2020 - 2021', 'digitized')),
            ({'end': '1999'}, ('', '1999', '')),
            ({'label': 'creation', 'date_type': 'bulk', 'begin': '1930', 'end': '1940'},
             ('', 'Majority of material found within 1930 - 1940', 'creation')),
            ({'label': 'creation', 'date_type': 'bulk', 'expression': '(bulk 1930)', 'begin': '1930'},
             ('', 'Majority of material found within ( 1930)', 'creation')),
        ]
        for date, expected in cases:
            with self.subTest(date=date):
                self.assertEqual(service._parse_date(date), expected)


if __name__ == '__main__':
    unittest.main()
