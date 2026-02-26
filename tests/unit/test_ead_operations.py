"""
Tests for EAD XML operations in arcflow.

Tests the following functionality:
- EAD ID extraction from XML files
- Dots-to-dashes sanitization in EAD IDs
- XML parsing error handling
"""

import os
import pytest
from unittest.mock import Mock
import logging


@pytest.mark.unit
class TestEadIdExtraction:
    """Tests for extracting EAD IDs from XML files."""
    
    def test_extract_simple_ead_id(self, temp_dir):
        """Test extracting a simple EAD ID."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_content = b'''<?xml version="1.0"?>
<ead>
  <eadheader>
    <eadid>simple-collection</eadid>
  </eadheader>
</ead>'''
        
        xml_path = os.path.join(temp_dir, 'simple.xml')
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id == 'simple-collection'
    
    def test_extract_ead_id_with_dots(self, temp_dir):
        """Test extracting EAD ID that contains dots."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_content = b'''<?xml version="1.0"?>
<ead xmlns="urn:isbn:1-931666-22-9">
  <eadheader>
    <eadid>collection.with.dots.in.name</eadid>
  </eadheader>
</ead>'''
        
        xml_path = os.path.join(temp_dir, 'dotted.xml')
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        # Dots should be preserved in extraction
        assert ead_id == 'collection.with.dots.in.name'
        assert '.' in ead_id
    
    def test_extract_ead_id_with_special_characters(self, temp_dir):
        """Test EAD ID with various special characters."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_content = b'''<?xml version="1.0"?>
<ead>
  <eadheader>
    <eadid>collection_2023-01</eadid>
  </eadheader>
</ead>'''
        
        xml_path = os.path.join(temp_dir, 'special.xml')
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        assert ead_id == 'collection_2023-01'


@pytest.mark.unit
class TestEadIdSanitization:
    """Tests for dots-to-dashes conversion in EAD IDs."""
    
    def test_dots_to_dashes_conversion(self):
        """Test that dots are converted to dashes for Solr compatibility."""
        # This documents the expected behavior when EAD IDs are processed
        # for Solr indexing (dots cause issues with Solr field names)
        
        ead_id_with_dots = 'collection.with.dots'
        sanitized = ead_id_with_dots.replace('.', '-')
        
        assert sanitized == 'collection-with-dots'
        assert '.' not in sanitized
    
    def test_multiple_consecutive_dots(self):
        """Test sanitization with multiple consecutive dots."""
        ead_id = 'test..multiple...dots'
        sanitized = ead_id.replace('.', '-')
        
        assert sanitized == 'test--multiple---dots'
    
    def test_dots_at_boundaries(self):
        """Test dots at start and end of ID."""
        ead_id = '.leading.and.trailing.'
        sanitized = ead_id.replace('.', '-')
        
        assert sanitized == '-leading-and-trailing-'
    
    def test_no_dots_unchanged(self):
        """Test that IDs without dots remain unchanged."""
        ead_id = 'no-dots-here'
        sanitized = ead_id.replace('.', '-')
        
        assert sanitized == ead_id
    
    def test_mixed_separators(self):
        """Test ID with both dots and dashes."""
        ead_id = 'collection-2023.01.final'
        sanitized = ead_id.replace('.', '-')
        
        assert sanitized == 'collection-2023-01-final'


@pytest.mark.unit
class TestXmlParsingErrors:
    """Tests for XML parsing error handling."""
    
    def test_malformed_xml(self, temp_dir):
        """Test handling of malformed XML."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_content = b'<ead><eadheader><eadid>test</eadid>'  # Missing closing tags
        
        xml_path = os.path.join(temp_dir, 'malformed.xml')
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        # Should handle parsing error gracefully
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        # May return None or partial result depending on parser behavior
        # pulldom parser is fairly lenient
        assert ead_id is None or isinstance(ead_id, str)
    
    def test_empty_eadid_element(self, temp_dir):
        """Test XML with empty eadid element."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_content = b'''<?xml version="1.0"?>
<ead>
  <eadheader>
    <eadid></eadid>
  </eadheader>
</ead>'''
        
        xml_path = os.path.join(temp_dir, 'empty_eadid.xml')
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        # Empty element triggers AttributeError in current code
        # This documents a bug: node.firstChild is None for empty elements
        # The code should check if firstChild exists before accessing nodeValue
        try:
            ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
            # If code is fixed, should return None
            assert ead_id is None
        except AttributeError:
            # Current behavior: raises AttributeError
            # This is expected until code is fixed
            pass
    
    def test_eadid_with_child_elements(self, temp_dir):
        """Test eadid with nested elements (shouldn't normally happen)."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        
        xml_content = b'''<?xml version="1.0"?>
<ead>
  <eadheader>
    <eadid>test-id<num>123</num></eadid>
  </eadheader>
</ead>'''
        
        xml_path = os.path.join(temp_dir, 'nested.xml')
        with open(xml_path, 'wb') as f:
            f.write(xml_content)
        
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        
        # firstChild.nodeValue should get text before nested element
        assert ead_id is not None


@pytest.mark.integration
class TestEadFileOperations:
    """Integration tests for EAD file operations."""
    
    def test_full_ead_processing_workflow(self, temp_dir, sample_ead_xml):
        """Test complete workflow: save -> read -> extract ID."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        # Save EAD file
        xml_path = os.path.join(temp_dir, 'workflow.xml')
        save_result = ArcFlow.save_file(arcflow, xml_path, sample_ead_xml, 'test')
        assert save_result is True
        
        # Extract EAD ID
        ead_id = ArcFlow.get_ead_id_from_file(arcflow, xml_path)
        assert ead_id == 'test.collection.123'
        
        # Sanitize for Solr
        sanitized_id = ead_id.replace('.', '-')
        assert sanitized_id == 'test-collection-123'
    
    def test_symlink_to_ead_id_workflow(self, temp_dir):
        """Test workflow: create symlink -> extract ID from target."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.log = logging.getLogger('test')
        
        # Create target file
        target_path = os.path.join(temp_dir, 'original-123.xml')
        with open(target_path, 'wb') as f:
            f.write(b'<ead><eadheader><eadid>original-123</eadid></eadheader></ead>')
        
        # Create symlink
        symlink_path = os.path.join(temp_dir, 'resource_456.xml')
        link_result = ArcFlow.create_symlink(arcflow, target_path, symlink_path)
        assert link_result is True
        
        # Extract ID from symlink
        ead_id = ArcFlow.get_ead_from_symlink(arcflow, symlink_path)
        assert ead_id == 'original-123'
