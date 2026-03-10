"""
Tests for AgentService.
"""

import unittest
from unittest.mock import Mock, MagicMock
from arcflow.services.agent_service import AgentService


class TestAgentService(unittest.TestCase):
    """Test cases for AgentService."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_client = Mock()
        self.mock_log = Mock()
        self.service = AgentService(client=self.mock_client, log=self.mock_log)

    def test_get_agent_bioghist_data_success(self):
        """Test successfully fetching agent bioghist data."""
        # Mock agent response
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'abc123',
                    'subnotes': [
                        {'content': 'First paragraph.\nSecond paragraph.'}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/corporate_entities/123')

        self.assertIsNotNone(result)
        self.assertEqual(result['agent_name'], 'Test Agent')
        self.assertEqual(result['persistent_id'], 'abc123')
        self.assertEqual(len(result['paragraphs']), 2)
        self.assertIn('<p>First paragraph.</p>', result['paragraphs'])
        self.assertIn('<p>Second paragraph.</p>', result['paragraphs'])

    def test_get_agent_bioghist_data_no_bioghist(self):
        """Test fetching agent with no bioghist notes."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': []
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/corporate_entities/123')

        self.assertIsNone(result)

    def test_get_agent_bioghist_data_with_list_content(self):
        """Test handling subnote content as a list."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'xyz789',
                    'subnotes': [
                        {'content': ['First item', 'Second item']}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/people/456')

        self.assertIsNotNone(result)
        self.assertEqual(len(result['paragraphs']), 2)
        self.assertIn('<p>First item</p>', result['paragraphs'])
        self.assertIn('<p>Second item</p>', result['paragraphs'])

    def test_get_agent_bioghist_data_filters_empty_lines(self):
        """Test that empty lines are filtered out."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'def456',
                    'subnotes': [
                        {'content': 'Line 1\n\n\nLine 2\n  \nLine 3'}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/families/789')

        self.assertIsNotNone(result)
        self.assertEqual(len(result['paragraphs']), 3)
        self.assertIn('<p>Line 1</p>', result['paragraphs'])
        self.assertIn('<p>Line 2</p>', result['paragraphs'])
        self.assertIn('<p>Line 3</p>', result['paragraphs'])

    def test_get_agent_bioghist_data_missing_persistent_id(self):
        """Test handling bioghist note without persistent_id."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    # No persistent_id
                    'subnotes': [
                        {'content': 'Some content'}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/corporate_entities/999')

        self.assertIsNotNone(result)
        self.assertIsNone(result['persistent_id'])
        # Should log error about missing persistent_id
        self.mock_log.error.assert_called()
        error_call = str(self.mock_log.error.call_args)
        self.assertIn('ASSUMPTION VIOLATION', error_call)
        self.assertIn('persistent_id', error_call)

    def test_get_agent_bioghist_data_invalid_content_type(self):
        """Test handling unexpected content type."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'ghi123',
                    'subnotes': [
                        {'content': {'unexpected': 'dict'}}  # Invalid type
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/corporate_entities/111')

        # Should return None when no valid paragraphs are extracted
        self.assertIsNone(result)
        # Should log error about unexpected type
        self.mock_log.error.assert_called()
        error_calls = [str(call) for call in self.mock_log.error.call_args_list]
        error_text = ''.join(error_calls)
        self.assertIn('ASSUMPTION VIOLATION', error_text)
        self.assertIn('dict', error_text)

    def test_get_agent_bioghist_data_uses_display_name_fallback(self):
        """Test using display_name.sort_name when title is missing."""
        mock_response = Mock()
        mock_response.json.return_value = {
            # No 'title' field
            'display_name': {'sort_name': 'Fallback Name'},
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'jkl456',
                    'subnotes': [
                        {'content': 'Some content'}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/people/222')

        self.assertIsNotNone(result)
        self.assertEqual(result['agent_name'], 'Fallback Name')

    def test_get_agent_bioghist_data_handles_exception(self):
        """Test handling exceptions during agent fetch."""
        self.mock_client.get.side_effect = Exception('Network error')

        result = self.service.get_agent_bioghist_data('/agents/corporate_entities/333')

        self.assertIsNone(result)
        self.mock_log.error.assert_called()
        error_call = str(self.mock_log.error.call_args)
        self.assertIn('Network error', error_call)

    def test_get_agent_bioghist_data_multiple_subnotes(self):
        """Test handling multiple subnotes in a bioghist note."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'mno789',
                    'subnotes': [
                        {'content': 'First subnote'},
                        {'content': 'Second subnote'},
                        {'content': 'Third subnote'}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/families/444')

        self.assertIsNotNone(result)
        self.assertEqual(len(result['paragraphs']), 3)
        self.assertIn('<p>First subnote</p>', result['paragraphs'])
        self.assertIn('<p>Second subnote</p>', result['paragraphs'])
        self.assertIn('<p>Third subnote</p>', result['paragraphs'])

    def test_get_agent_bioghist_data_returns_first_bioghist_only(self):
        """Test that only the first bioghist note is returned."""
        mock_response = Mock()
        mock_response.json.return_value = {
            'title': 'Test Agent',
            'notes': [
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'first123',
                    'subnotes': [
                        {'content': 'First bioghist'}
                    ]
                },
                {
                    'jsonmodel_type': 'note_bioghist',
                    'persistent_id': 'second456',
                    'subnotes': [
                        {'content': 'Second bioghist'}
                    ]
                }
            ]
        }
        self.mock_client.get.return_value = mock_response

        result = self.service.get_agent_bioghist_data('/agents/corporate_entities/555')

        self.assertIsNotNone(result)
        self.assertEqual(result['persistent_id'], 'first123')
        self.assertIn('<p>First bioghist</p>', result['paragraphs'])
        self.assertNotIn('<p>Second bioghist</p>', result['paragraphs'])


if __name__ == '__main__':
    unittest.main()
