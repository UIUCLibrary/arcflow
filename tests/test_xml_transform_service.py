"""
Tests for XmlTransformService.
"""

import unittest
from unittest.mock import Mock
from arcflow.services.xml_transform_service import XmlTransformService

# Real ArchivesSpace EAD fixture with namespace
REAL_EAD_WITH_NAMESPACE = '''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink">
  <eadheader>
    <eadid>test-collection</eadid>
  </eadheader>
  <archdesc level="collection">
    <did>
      <unittitle>Test Collection with Namespace</unittitle>
      <origination label="Creator">
        <corpname source="lcnaf">Test Corporation</corpname>
      </origination>
    </did>
  </archdesc>
</ead>'''

# Real EAC-CPF fixture with namespace
REAL_EAC_CPF_WITH_NAMESPACE = '''<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink">
  <control>
    <recordId>test-agent</recordId>
  </control>
  <cpfDescription>
    <relations>
      <resourceRelation resourceRelationType="creatorOf" 
                       xlink:href="https://aspace.test/repositories/2/resources/123">
        <relationEntry>Test Collection</relationEntry>
      </resourceRelation>
    </relations>
  </cpfDescription>
</eac-cpf>'''

class TestXmlTransformService(unittest.TestCase):
    """Test cases for XmlTransformService."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_client = Mock()
        self.mock_log = Mock()
        self.service = XmlTransformService(client=self.mock_client, log=self.mock_log)

    def test_add_creator_ids_to_ead(self):
        """Test adding arcuit:creator_id attributes to origination elements."""

        resource = {
            'linked_agents': [
                {'role': 'creator', 'ref': '/agents/corporate_entities/123'}
            ]
        }

        result = self.service.add_creator_ids_to_ead(REAL_EAD_WITH_NAMESPACE, resource)

        # Should contain arcuit namespace declaration
        self.assertIn('xmlns:arcuit', result)
        self.assertIn('https://arcuit.library.illinois.edu/ead-extensions', result)
        # Should contain the creator_id attribute
        self.assertIn('creator_id="creator_corporate_entities_123"', result)
        # Should preserve EAD namespace
        self.assertIn('urn:isbn:1-931666-22-9', result)
        # Should still find and modify the corpname element
        self.assertIn('corpname', result)

    def test_add_creator_ids_multiple_creators(self):
        """Test adding arcuit:creator_id to multiple origination elements."""
        xml_content = '''<ead>
<origination label="Creator">
  <corpname source="lcnaf">First Corp</corpname>
</origination>
<origination label="Creator">
  <persname source="lcnaf">Second Person</persname>
</origination>
</ead>'''

        resource = {
            'linked_agents': [
                {'role': 'creator', 'ref': '/agents/corporate_entities/123'},
                {'role': 'creator', 'ref': '/agents/people/456'}
            ]
        }

        result = self.service.add_creator_ids_to_ead(xml_content, resource)

        self.assertIn('creator_id="creator_corporate_entities_123"', result)
        self.assertIn('creator_id="creator_people_456"', result)
        self.assertIn('xmlns:arcuit', result)

    def test_add_creator_ids_no_creators(self):
        """Test that XML is unchanged when there are no creators."""
        xml_content = '<ead><origination><corpname>Test</corpname></origination></ead>'
        resource = {'linked_agents': []}

        result = self.service.add_creator_ids_to_ead(xml_content, resource)

        self.assertEqual(xml_content, result)

    def test_inject_collection_metadata_with_all_fields(self):
        """Test injecting record group, subgroup, and bioghist."""
        xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
        <ead xmlns="urn:isbn:1-931666-22-9">
          <archdesc level="collection">
            <did>
              <unittitle>Test Collection</unittitle>
            </did>
          </archdesc>
        </ead>'''

        result = self.service.inject_collection_metadata(
            xml_content,
            record_group='RG 1 — Test Group',
            subgroup='SG 1.1 — Test Subgroup',
            bioghist_content='<bioghist><p>Test bioghist</p></bioghist>'
        )

        # Should add recordgroup with namespace
        self.assertIn('recordgroup', result)
        self.assertIn('RG 1 — Test Group', result)
        # Should add subgroup with namespace
        self.assertIn('subgroup', result)
        self.assertIn('SG 1.1 — Test Subgroup', result)
        # Should add bioghist with EAD namespace
        self.assertIn('bioghist', result)
        self.assertIn('Test bioghist', result)
        # Should preserve original namespace
        self.assertIn('xmlns', result)
        self.assertIn('urn:isbn:1-931666-22-9', result)

    def test_inject_collection_metadata_into_existing_bioghist(self):
        """Test that bioghist content is inserted into existing bioghist element."""
        xml_content = '''<ead>
<archdesc level="collection">
  <did>
    <unittitle>Test Collection</unittitle>
  </did>
  <bioghist>
    <p>Existing content</p>
  </bioghist>
</archdesc>
</ead>'''

        result = self.service.inject_collection_metadata(
            xml_content,
            record_group=None,
            subgroup=None,
            bioghist_content='<bioghist><p>New content</p></bioghist>'
        )

        # Should insert before </bioghist>
        self.assertIn('Existing content', result)
        self.assertIn('New content', result)
        # Should not create a new bioghist wrapper
        self.assertEqual(result.count('<bioghist>'), 2)  # Original + inserted

    def test_inject_collection_metadata_xml_escaping(self):
        """Test that special XML characters are properly escaped."""
        xml_content = '''<ead>
<archdesc level="collection">
  <did>
    <unittitle>Test</unittitle>
  </did>
</archdesc>
</ead>'''

        result = self.service.inject_collection_metadata(
            xml_content,
            record_group='Group & Co <test>',
            subgroup=None,
            bioghist_content=None
        )

        self.assertIn('Group &amp; Co &lt;test&gt;', result)
        self.assertNotIn('Group & Co <test>', result)

    def test_add_collection_links_to_eac_cpf(self):
        """Test adding ead_id descriptiveNote to resourceRelation elements."""

        # Mock the client response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'ead_id': 'TEST.1.2.3'}
        self.mock_client.get.return_value = mock_response

        result = self.service.add_collection_links_to_eac_cpf(REAL_EAC_CPF_WITH_NAMESPACE)

        # Should add descriptiveNote (namespace-aware check)
        self.assertIn('descriptiveNote', result)
        self.assertIn('ead_id:TEST.1.2.3', result)
        # Should preserve EAC-CPF namespace
        self.assertIn('urn:isbn:1-931666-33-4', result)

    def test_multiple_creators_with_namespace(self):
        """Test handling multiple creators when EAD has default namespace."""
        xml_with_namespace = '''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9">
  <archdesc level="collection">
    <did>
      <origination label="Creator">
        <corpname source="lcnaf">First Corp</corpname>
      </origination>
      <origination label="Creator">
        <persname source="lcnaf">Second Person</persname>
      </origination>
    </did>
  </archdesc>
</ead>'''

        resource = {
            'linked_agents': [
                {'role': 'creator', 'ref': '/agents/corporate_entities/123'},
                {'role': 'creator', 'ref': '/agents/people/456'}
            ]
        }

        result = self.service.add_creator_ids_to_ead(xml_with_namespace, resource)

        # Should add both creator IDs
        self.assertIn('creator_id="creator_corporate_entities_123"', result)
        self.assertIn('creator_id="creator_people_456"', result)
        # Should preserve namespace
        self.assertIn('urn:isbn:1-931666-22-9', result)

    def test_add_collection_links_idempotent(self):
        """Test that adding collection links is idempotent."""
        eac_cpf_xml = '''<eac-cpf>
<resourceRelation resourceRelationType="creatorOf" xlink:href="https://aspace.test/repositories/2/resources/123">
  <relationEntry>Test Collection</relationEntry>
  <descriptiveNote>
    <p>ead_id:TEST.1.2.3</p>
  </descriptiveNote>
</resourceRelation>
</eac-cpf>'''

        result = self.service.add_collection_links_to_eac_cpf(eac_cpf_xml)

        # Should not call the client since descriptiveNote already exists
        self.mock_client.get.assert_not_called()
        # Should return unchanged XML
        self.assertEqual(eac_cpf_xml, result)

    def test_add_collection_links_skips_digital_objects(self):
        """Test that digital object URLs are skipped silently."""
        eac_cpf_xml = '''<eac-cpf>
<resourceRelation resourceRelationType="creatorOf" xlink:href="https://aspace.test/repositories/2/digital_objects/123">
  <relationEntry>Test Digital Object</relationEntry>
</resourceRelation>
</eac-cpf>'''

        result = self.service.add_collection_links_to_eac_cpf(eac_cpf_xml)

        # Should not call the client
        self.mock_client.get.assert_not_called()
        # Should return unchanged XML
        self.assertEqual(eac_cpf_xml, result)

    def test_add_collection_links_handles_fetch_errors(self):
        """Test that fetch errors are handled gracefully."""
        eac_cpf_xml = '''<eac-cpf>
<resourceRelation resourceRelationType="creatorOf" xlink:href="https://aspace.test/repositories/2/resources/123">
  <relationEntry>Test Collection</relationEntry>
</resourceRelation>
</eac-cpf>'''

        # Mock a 404 response
        mock_response = Mock()
        mock_response.status_code = 404
        self.mock_client.get.return_value = mock_response

        result = self.service.add_collection_links_to_eac_cpf(eac_cpf_xml)

        # Should log a warning
        self.mock_log.warning.assert_called()
        # Should return unchanged XML
        self.assertNotIn('<descriptiveNote>', result)

    def test_build_bioghist_element(self):
        """Test building bioghist XML element from structured data."""
        result = self.service.build_bioghist_element(
            agent_name='Test Agent',
            persistent_id='abc123',
            paragraphs=['First paragraph', 'Second paragraph']
        )

        self.assertIn('<bioghist id="aspace_abc123">', result)
        self.assertIn('<head>Historical Note from Test Agent Creator Record</head>', result)
        self.assertIn('<p>First paragraph</p>', result)
        self.assertIn('<p>Second paragraph</p>', result)
        self.assertIn('</bioghist>', result)

    def test_build_bioghist_element_without_persistent_id(self):
        """Test building bioghist without persistent_id."""
        result = self.service.build_bioghist_element(
            agent_name='Test Agent',
            persistent_id=None,
            paragraphs=['Content']
        )

        self.assertIn('<bioghist>', result)
        self.assertNotIn('id=', result)
        self.assertIn('<p>Content</p>', result)

    def test_build_bioghist_element_escapes_agent_name(self):
        """Test that agent name is properly XML-escaped."""
        result = self.service.build_bioghist_element(
            agent_name='Agent & Co <test>',
            persistent_id='abc',
            paragraphs=['Content']
        )

        self.assertIn('Agent &amp; Co &lt;test&gt;', result)

    def test_build_bioghist_element_escapes_paragraph_content(self):
        """Test that paragraph content with special XML characters is properly escaped."""
        result = self.service.build_bioghist_element(
            agent_name='Test Agent',
            persistent_id='abc',
            paragraphs=['Content with & ampersand', 'Content with <tags> and "quotes"']
        )

        self.assertIn('<p>Content with &amp; ampersand</p>', result)
        self.assertIn('<p>Content with &lt;tags&gt; and "quotes"</p>', result)

    def test_validate_eac_cpf_xml_valid(self):
        """Test validating valid EAC-CPF XML."""
        eac_cpf_xml = '<eac-cpf><control></control></eac-cpf>'

        root = self.service.validate_eac_cpf_xml(eac_cpf_xml, '/agents/corporate_entities/123')

        self.assertIsNotNone(root)
        self.assertEqual(root.tag, 'eac-cpf')

    def test_validate_eac_cpf_xml_invalid(self):
        """Test validating invalid EAC-CPF XML."""
        eac_cpf_xml = '<eac-cpf><control>'  # Missing closing tags

        root = self.service.validate_eac_cpf_xml(eac_cpf_xml, '/agents/corporate_entities/123')

        self.assertIsNone(root)
        self.mock_log.error.assert_called()

    def test_add_collection_links_requires_client(self):
        """Test that add_collection_links_to_eac_cpf requires a client."""
        service_no_client = XmlTransformService(client=None)

        with self.assertRaises(ValueError) as context:
            service_no_client.add_collection_links_to_eac_cpf('<eac-cpf></eac-cpf>')

        self.assertIn('Client is required', str(context.exception))

    def test_namespace_preservation_ead_with_declaration(self):
        """Test that EAD namespace prefixes and XML declaration are preserved."""
        xml_input = '''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink">
  <eadheader>
    <eadid>test-collection</eadid>
  </eadheader>
  <archdesc level="collection">
    <did>
      <unittitle>Test Collection</unittitle>
      <origination label="Creator">
        <corpname source="lcnaf">Test Corporation</corpname>
      </origination>
    </did>
  </archdesc>
</ead>'''
        
        resource = {
            'linked_agents': [
                {'role': 'creator', 'ref': '/agents/corporate_entities/123'}
            ]
        }
        
        result = self.service.add_creator_ids_to_ead(xml_input, resource)
        
        # Should have XML declaration
        self.assertTrue(result.startswith('<?xml'), 'XML declaration should be preserved')
        self.assertIn('version', result[:50])  # Check in first 50 chars
        self.assertIn('1.0', result[:50])
        self.assertIn('encoding', result[:50])
        self.assertIn('UTF-8', result[:50])
        
        # Should preserve default EAD namespace (not rewrite to ns0:)
        self.assertIn('xmlns="urn:isbn:1-931666-22-9"', result)
        self.assertNotIn('ns0:', result, 'Default namespace should not be rewritten to ns0:')
        
        # Should preserve xlink namespace
        self.assertIn('xmlns:xlink="http://www.w3.org/1999/xlink"', result)
        
        # Should add arcuit namespace
        self.assertIn('xmlns:arcuit="https://arcuit.library.illinois.edu/ead-extensions"', result)
        
        # Tags should use default namespace, not prefixed
        self.assertIn('<ead ', result)
        self.assertIn('<archdesc ', result)
        self.assertNotIn('<ns0:ead', result)

    def test_namespace_preservation_eac_cpf_with_declaration(self):
        """Test that EAC-CPF namespace prefixes and XML declaration are preserved."""
        xml_input = '''<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink">
  <control>
    <recordId>test-agent</recordId>
  </control>
  <cpfDescription>
    <relations>
      <resourceRelation resourceRelationType="creatorOf" 
                       xlink:href="https://aspace.test/repositories/2/resources/123">
        <relationEntry>Test Collection</relationEntry>
      </resourceRelation>
    </relations>
  </cpfDescription>
</eac-cpf>'''
        
        # Mock the client response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'ead_id': 'TEST.1.2.3'}
        self.mock_client.get.return_value = mock_response
        
        result = self.service.add_collection_links_to_eac_cpf(xml_input)
        
        # Should have XML declaration
        self.assertTrue(result.startswith('<?xml'), 'XML declaration should be preserved')
        self.assertIn('version', result[:50])  # Check in first 50 chars
        self.assertIn('1.0', result[:50])
        self.assertIn('encoding', result[:50])
        self.assertIn('UTF-8', result[:50])
        
        # Should preserve default EAC-CPF namespace (not rewrite to ns0:)
        self.assertIn('xmlns="urn:isbn:1-931666-33-4"', result)
        self.assertNotIn('ns0:', result, 'Default namespace should not be rewritten to ns0:')
        
        # Should preserve xlink namespace
        self.assertIn('xmlns:xlink="http://www.w3.org/1999/xlink"', result)
        
        # Tags should use default namespace, not prefixed
        self.assertIn('<eac-cpf ', result)
        self.assertIn('<resourceRelation ', result)
        self.assertNotIn('<ns0:eac-cpf', result)

    def test_namespace_preservation_inject_metadata(self):
        """Test that inject_collection_metadata preserves namespaces."""
        xml_input = '''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9">
  <eadheader>
    <eadid>test-collection</eadid>
  </eadheader>
  <archdesc level="collection">
    <did>
      <unittitle>Test Collection</unittitle>
    </did>
  </archdesc>
</ead>'''
        
        bioghist_content = '''<bioghist id="aspace_123">
  <head>Historical Note from Test Agent Creator Record</head>
  <p>Test paragraph</p>
</bioghist>'''
        
        result = self.service.inject_collection_metadata(
            xml_input,
            record_group="Test Group",
            subgroup="Test Subgroup",
            bioghist_content=bioghist_content
        )
        
        # Should have XML declaration
        self.assertTrue(result.startswith('<?xml'), 'XML declaration should be preserved')
        
        # Should preserve default EAD namespace
        self.assertIn('xmlns="urn:isbn:1-931666-22-9"', result)
        self.assertNotIn('ns0:', result, 'Default namespace should not be rewritten to ns0:')
        
        # Inserted elements should be in same namespace (no xmlns="" pollution)
        self.assertNotIn('xmlns=""', result, 'Should not have empty namespace declarations')
        
        # Tags should use default namespace, not prefixed
        self.assertIn('<recordgroup>', result)
        self.assertIn('<subgroup>', result)
        self.assertIn('<bioghist ', result)
        self.assertNotIn('<ns0:recordgroup', result)

    def test_namespace_preservation_no_declaration_maintained(self):
        """Test that documents without XML declaration remain without it when no changes made."""
        xml_input = '''<eac-cpf>
<control>
  <recordId>test-agent</recordId>
</control>
</eac-cpf>'''
        
        # No changes will be made (no resourceRelations)
        result = self.service.add_collection_links_to_eac_cpf(xml_input)
        
        # Should not add XML declaration when original didn't have one and no changes made
        self.assertEqual(xml_input, result, 'Unchanged XML should be returned as-is')
        self.assertFalse(result.startswith('<?xml'), 'Should not add XML declaration to unchanged document')


if __name__ == '__main__':
    unittest.main()
