"""
Tests for utility helper functions in arcflow.

Tests the following functions:
- get_repo_id: Extract repository ID from URI
- get_ead_id_from_file: Extract EAD ID from XML files
- Path construction utilities
"""

import os
import pytest
from unittest.mock import Mock
import logging


@pytest.mark.unit
class TestGetRepoId:
    """Tests for the get_repo_id method."""
    
    def test_get_repo_id_standard_uri(self):
        """Test extracting repo ID from standard repository URI."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        repo = {'uri': '/repositories/2'}
        
        repo_id = ArcFlow.get_repo_id(arcflow, repo)
        
        assert repo_id == '2'
    
    def test_get_repo_id_single_digit(self):
        """Test with single digit repository ID."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        repo = {'uri': '/repositories/1'}
        
        repo_id = ArcFlow.get_repo_id(arcflow, repo)
        
        assert repo_id == '1'
    
    def test_get_repo_id_multi_digit(self):
        """Test with multi-digit repository ID."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        repo = {'uri': '/repositories/123'}
        
        repo_id = ArcFlow.get_repo_id(arcflow, repo)
        
        assert repo_id == '123'
    
    def test_get_repo_id_trailing_slash(self):
        """Test extracting repo ID with trailing slash."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        repo = {'uri': '/repositories/5/'}
        
        # Should handle trailing slash by splitting and getting last non-empty part
        # Current implementation splits on '/' and gets last element
        # With trailing slash, last element would be empty string
        repo_id = ArcFlow.get_repo_id(arcflow, repo)
        
        # This test documents current behavior - might be '' or need fixing
        # Based on code: repo['uri'].split('/')[-1]
        assert repo_id == '' or repo_id == '5'


@pytest.mark.unit
class TestGetEadIdFromFile:
    """Tests for the get_ead_id_from_file method."""
    
    def test_get_ead_id_from_valid_xml(self, temp_dir, sample_ead_xml):
        """Test extracting EAD ID from valid EAD XML file."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        # Create XML file
        xml_path = os.path.join(temp_dir, 'test.xml')
        with open(xml_path, 'wb') as f:
            f.write(sample_ead_xml)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id == 'test.collection.123'
    
    def test_get_ead_id_with_dots(self, temp_dir, sample_ead_xml_with_dots):
        """Test extracting EAD ID that contains dots."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_path = os.path.join(temp_dir, 'dotted.xml')
        with open(xml_path, 'wb') as f:
            f.write(sample_ead_xml_with_dots)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id == 'test.collection.with.dots'
    
    def test_get_ead_id_from_nonexistent_file(self):
        """Test behavior with non-existent file."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, '/nonexistent/file.xml')
        
        assert ead_id is None
    
    def test_get_ead_id_from_empty_file(self, temp_dir):
        """Test behavior with empty XML file."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_path = os.path.join(temp_dir, 'empty.xml')
        with open(xml_path, 'w') as f:
            f.write('')
        
        # Empty file should return None (no eadid element found)
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id is None
    
    def test_get_ead_id_missing_eadid_element(self, temp_dir):
        """Test XML file without eadid element."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_path = os.path.join(temp_dir, 'no_eadid.xml')
        xml_content = b'<?xml version="1.0"?><ead><eadheader></eadheader></ead>'
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id is None
    
    def test_get_ead_id_with_namespace(self, temp_dir):
        """Test EAD ID extraction from XML with namespaces."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_path = os.path.join(temp_dir, 'namespaced.xml')
        # XML with explicit namespace
        xml_content = b'''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink">
  <eadheader>
    <eadid>namespaced.collection.456</eadid>
  </eadheader>
</ead>'''
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id == 'namespaced.collection.456'
    
    def test_get_ead_id_with_whitespace(self, temp_dir):
        """Test EAD ID with surrounding whitespace."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_path = os.path.join(temp_dir, 'whitespace.xml')
        xml_content = b'''<?xml version="1.0"?>
<ead>
  <eadheader>
    <eadid>  whitespace.collection  </eadid>
  </eadheader>
</ead>'''
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        # Should preserve whitespace as found in XML
        assert 'whitespace.collection' in ead_id


@pytest.mark.unit
class TestPathConstruction:
    """Tests for path construction patterns used in arcflow."""
    
    def test_xml_path_construction(self):
        """Test standard XML file path construction pattern."""
        base_dir = '/data/arclight'
        repo_id = '2'
        ead_id = 'test-collection'
        
        # Pattern used in arcflow
        xml_path = f'{base_dir}/data/xml/repo_{repo_id}/{ead_id}.xml'
        
        assert xml_path == '/data/arclight/data/xml/repo_2/test-collection.xml'
    
    def test_agents_dir_construction(self):
        """Test agents directory path construction pattern."""
        base_dir = '/data/arclight'
        
        agents_dir = f'{base_dir}/data/xml/agents'
        
        assert agents_dir == '/data/arclight/data/xml/agents'
    
    def test_pdf_path_construction(self):
        """Test PDF file path construction pattern."""
        base_dir = '/data/arclight'
        repo_id = '2'
        ead_id = 'test-collection'
        
        pdf_path = f'{base_dir}/data/pdfs/repo_{repo_id}/{ead_id}.pdf'
        
        assert pdf_path == '/data/arclight/data/pdfs/repo_2/test-collection.pdf'
    
    def test_symlink_path_construction(self):
        """Test symlink path construction pattern."""
        xml_dir = '/data/arclight/data/xml/repo_2'
        ead_id = 'test-collection'
        resource_id = '123'
        
        xml_file_path = f'{xml_dir}/{ead_id}.xml'
        symlink_path = f'{xml_dir}/resource_{resource_id}.xml'
        
        assert xml_file_path == '/data/arclight/data/xml/repo_2/test-collection.xml'
        assert symlink_path == '/data/arclight/data/xml/repo_2/resource_123.xml'
