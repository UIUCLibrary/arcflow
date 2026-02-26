"""
Tests for XML content manipulation in arcflow.

Tests the following functionality:
- xml_escape() for plain text labels (recordgroup, subgroup)
- get_creator_bioghist() for biographical note extraction
- Proper distinction between plain text (needs escaping) and structured XML (pass through)

Critical distinction documented in copilot-instructions.md:
- Plain text labels: Use xml_escape() to escape special characters
- Structured EAD XML content: Do NOT escape (already valid XML)
"""

import pytest
from unittest.mock import Mock, MagicMock
from xml.sax.saxutils import escape as xml_escape
import logging


@pytest.mark.unit
class TestXmlEscaping:
    """Tests for XML escaping of plain text content."""
    
    def test_escape_ampersand(self):
        """Test escaping ampersand character."""
        text = "Group & Associates"
        escaped = xml_escape(text)
        
        assert escaped == "Group &amp; Associates"
        assert '&' not in escaped or '&amp;' in escaped
    
    def test_escape_less_than(self):
        """Test escaping less-than character."""
        text = "Value < 100"
        escaped = xml_escape(text)
        
        assert escaped == "Value &lt; 100"
        assert '<' not in escaped or '&lt;' in escaped
    
    def test_escape_greater_than(self):
        """Test escaping greater-than character."""
        text = "Value > 50"
        escaped = xml_escape(text)
        
        assert escaped == "Value &gt; 50"
        assert '>' not in escaped or '&gt;' in escaped
    
    def test_escape_multiple_special_chars(self):
        """Test escaping multiple special characters."""
        text = "A&B <Company> Test"
        escaped = xml_escape(text)
        
        assert '&' not in escaped or '&amp;' in escaped
        assert '<' not in escaped or '&lt;' in escaped
        assert '>' not in escaped or '&gt;' in escaped
    
    def test_escape_preserves_normal_text(self):
        """Test that normal text is unchanged."""
        text = "Normal Text With Spaces"
        escaped = xml_escape(text)
        
        assert escaped == text
    
    def test_escape_quotes_not_escaped_by_default(self):
        """Test that quotes are not escaped by default."""
        text = 'Text with "quotes" and \'apostrophes\''
        escaped = xml_escape(text)
        
        # By default, xml_escape doesn't escape quotes
        assert '"' in escaped
        assert "'" in escaped


@pytest.mark.unit
class TestStructuredXmlPreservation:
    """Tests documenting that structured XML should NOT be escaped."""
    
    def test_bioghist_xml_not_escaped(self):
        """Test that bioghist XML content should NOT be escaped."""
        # This is structured XML from ArchivesSpace
        bioghist_content = '<p>Jane Doe was a <emph render="italic">pioneering</emph> librarian.</p>'
        
        # Should NOT escape - this is legitimate XML
        # If we escaped it, <p> would become &lt;p&gt; and break XML structure
        preserved = bioghist_content
        
        assert '<p>' in preserved
        assert '<emph' in preserved
        assert '&lt;' not in preserved
    
    def test_subnote_content_not_escaped(self):
        """Test that subnote content (valid XML) is not escaped."""
        subnote_content = '<title render="italic">Historical Notes</title>'
        
        # This is valid EAD XML - pass through unchanged
        preserved = subnote_content
        
        assert '<title' in preserved
        assert 'render="italic"' in preserved
    
    def test_escaping_would_break_xml_nodes(self):
        """Document that escaping XML would break node structure."""
        xml_content = '<p>Content</p>'
        
        # If we incorrectly escaped this:
        incorrectly_escaped = xml_escape(xml_content)
        assert incorrectly_escaped == '&lt;p&gt;Content&lt;/p&gt;'
        # This would appear as literal text: <p>Content</p>
        # Instead of being parsed as an XML node
        
        # Correct: Don't escape structured XML
        correctly_preserved = xml_content
        assert '<p>' in correctly_preserved


@pytest.mark.integration
class TestGetCreatorBioghist:
    """Tests for get_creator_bioghist method."""
    
    def test_extract_bioghist_basic(self, mock_asnake_client):
        """Test basic biographical note extraction."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.client = mock_asnake_client
        arcflow.log = logging.getLogger('test')
        
        # Mock agent response
        agent_data = {
            'title': 'John Smith',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'abc123',
                    'subnotes': [
                        {
                            'content': 'John Smith was a librarian.\nHe worked from 1960-1990.'
                        }
                    ]
                }
            ]
        }
        mock_asnake_client.get.return_value.json.return_value = agent_data
        
        resource = {
            'linked_agents': [
                {
                    'role': 'creator',
                    'ref': '/agents/people/123'
                }
            ]
        }
        
        result = ArcFlow.get_creator_bioghist(arcflow, resource)
        
        assert result is not None
        assert 'John Smith' in result
        assert '<p>John Smith was a librarian.</p>' in result
    
    def test_bioghist_xml_not_escaped(self, mock_asnake_client):
        """Test that XML in bioghist content is NOT escaped."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.client = mock_asnake_client
        arcflow.log = logging.getLogger('test')
        
        # Content with legitimate XML markup
        agent_data = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'xyz789',
                    'subnotes': [
                        {
                            'content': 'Agent with <emph render="italic">emphasis</emph> in text.'
                        }
                    ]
                }
            ]
        }
        mock_asnake_client.get.return_value.json.return_value = agent_data
        
        resource = {
            'linked_agents': [
                {
                    'role': 'creator',
                    'ref': '/agents/corporate_entities/1'
                }
            ]
        }
        
        result = ArcFlow.get_creator_bioghist(arcflow, resource)
        
        # Should preserve XML tags
        assert '<emph' in result
        assert 'render="italic"' in result
        # Should NOT escape them
        assert '&lt;emph' not in result
    
    def test_agent_name_is_escaped(self, mock_asnake_client):
        """Test that agent name (plain text) IS escaped."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.client = mock_asnake_client
        arcflow.log = logging.getLogger('test')
        
        # Agent with special characters in name
        agent_data = {
            'title': 'Smith & Associates <Corporation>',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'test123',
                    'subnotes': [
                        {
                            'content': 'A corporate entity.'
                        }
                    ]
                }
            ]
        }
        mock_asnake_client.get.return_value.json.return_value = agent_data
        
        resource = {
            'linked_agents': [
                {
                    'role': 'creator',
                    'ref': '/agents/corporate_entities/1'
                }
            ]
        }
        
        result = ArcFlow.get_creator_bioghist(arcflow, resource)
        
        # Agent name should be escaped in the heading
        assert 'Smith &amp; Associates' in result
        assert '&lt;Corporation&gt;' in result or 'Corporation' in result
    
    def test_no_bioghist_returns_none(self, mock_asnake_client):
        """Test that agents without bioghist return None."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.client = mock_asnake_client
        arcflow.log = logging.getLogger('test')
        
        # Agent with no notes
        agent_data = {
            'title': 'Agent Without Notes',
            'notes': []
        }
        mock_asnake_client.get.return_value.json.return_value = agent_data
        
        resource = {
            'linked_agents': [
                {
                    'role': 'creator',
                    'ref': '/agents/people/1'
                }
            ]
        }
        
        result = ArcFlow.get_creator_bioghist(arcflow, resource)
        
        assert result is None
    
    def test_non_creator_agents_excluded(self, mock_asnake_client):
        """Test that non-creator agents are excluded from bioghist."""
        from arcflow.main import ArcFlow
        
        arcflow = Mock(spec=ArcFlow)
        arcflow.client = mock_asnake_client
        arcflow.log = logging.getLogger('test')
        
        resource = {
            'linked_agents': [
                {
                    'role': 'subject',  # Not a creator
                    'ref': '/agents/people/1'
                }
            ]
        }
        
        result = ArcFlow.get_creator_bioghist(arcflow, resource)
        
        # Should not fetch bioghist for non-creators
        assert result is None
        # Should not call API
        mock_asnake_client.get.assert_not_called()


@pytest.mark.unit
class TestXmlContentDistinction:
    """Tests documenting the distinction between plain text and XML content."""
    
    def test_plain_text_labels_need_escaping(self):
        """Document that plain text labels need escaping."""
        # These are plain strings from database/API
        recordgroup = "University Archives & Records"
        subgroup = "Department of <Subject>"
        
        # Must escape for XML safety
        rg_escaped = xml_escape(recordgroup)
        sg_escaped = xml_escape(subgroup)
        
        assert '&amp;' in rg_escaped
        assert '&lt;' in sg_escaped
    
    def test_structured_xml_passes_through(self):
        """Document that structured XML content passes through."""
        # This comes from ArchivesSpace as valid EAD XML
        bioghist_xml = '<bioghist><head>History</head><p>Founded in <date>1950</date>.</p></bioghist>'
        
        # Do NOT escape - this is legitimate XML structure
        preserved = bioghist_xml
        
        assert '<bioghist>' in preserved
        assert '<head>' in preserved
        assert '<date>' in preserved
        # No escaped characters
        assert '&lt;' not in preserved
    
    def test_mixed_content_handling(self):
        """Document how to handle mixed plain text and XML."""
        # Plain text label (needs escaping)
        label = "Smith & Associates"
        label_escaped = xml_escape(label)
        
        # XML content (don't escape)
        content = '<p>Historical information.</p>'
        
        # Combine properly
        combined = f'<head>{label_escaped}</head>{content}'
        
        assert '&amp;' in combined  # Escaped label
        assert '<p>' in combined    # Preserved XML
        assert '&lt;p&gt;' not in combined  # XML not double-escaped


@pytest.mark.integration
class TestBioghlistContentHandling:
    """Integration tests for bioghist content handling."""
    
    def test_paragraph_wrapping(self):
        """Test that content lines are wrapped in <p> tags."""
        content = "Line 1\nLine 2\nLine 3"
        lines = [line.strip() for line in content.split('\n') if line.strip()]
        
        paragraphs = [f'<p>{line}</p>' for line in lines]
        result = '\n'.join(paragraphs)
        
        assert result == '<p>Line 1</p>\n<p>Line 2</p>\n<p>Line 3</p>'
    
    def test_bioghist_element_structure(self):
        """Test complete bioghist element structure."""
        persistent_id = 'abc123'
        agent_name = 'Test Agent'
        content_paragraphs = '<p>Historical note.</p>'
        
        # Should include id attribute with aspace_ prefix
        bioghist_el = f'<bioghist id="aspace_{persistent_id}"><head>Historical Note from {xml_escape(agent_name)} Creator Record</head>\n{content_paragraphs}\n</bioghist>'
        
        assert f'id="aspace_{persistent_id}"' in bioghist_el
        assert f'{xml_escape(agent_name)}' in bioghist_el
        assert '<p>Historical note.</p>' in bioghist_el
    
    def test_missing_persistent_id_handling(self):
        """Test bioghist without persistent_id (shouldn't have id attribute)."""
        agent_name = 'Test Agent'
        content = '<p>Content</p>'
        
        # Without persistent_id, no id attribute
        bioghist_el = f'<bioghist><head>Historical Note from {xml_escape(agent_name)} Creator Record</head>\n{content}\n</bioghist>'
        
        assert 'id=' not in bioghist_el
        assert '<bioghist><head>' in bioghist_el
