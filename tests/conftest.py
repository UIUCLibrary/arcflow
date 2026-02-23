"""
Shared pytest fixtures for arcflow tests.

Provides common test fixtures including:
- mock_asnake_client: Mock ArchivesSpace client for testing without API calls
- temp_dir: Temporary directory for test file operations
- sample_*: Sample data structures representing ArchivesSpace API responses
"""

import os
import tempfile
import shutil
import pytest
from unittest.mock import Mock, MagicMock
from datetime import datetime, timezone


@pytest.fixture
def temp_dir():
    """Create a temporary directory for test file operations."""
    temp_path = tempfile.mkdtemp()
    yield temp_path
    # Cleanup after test
    if os.path.exists(temp_path):
        shutil.rmtree(temp_path)


@pytest.fixture
def mock_asnake_client():
    """Create a mock ASnake client for testing."""
    mock_client = Mock()
    mock_client.authorize = Mock()
    mock_client.config = {'baseurl': 'http://localhost:8089'}
    
    # Mock the get method to return a mock response
    mock_response = Mock()
    mock_response.json = Mock(return_value={})
    mock_client.get = Mock(return_value=mock_response)
    
    return mock_client


@pytest.fixture
def sample_repository():
    """Sample repository data from ArchivesSpace API."""
    return {
        'uri': '/repositories/2',
        'name': 'Test Repository',
        'repo_code': 'test_repo',
        'slug': 'test-repository'
    }


@pytest.fixture
def sample_resource():
    """Sample resource (collection) data from ArchivesSpace API."""
    return {
        'uri': '/repositories/2/resources/123',
        'id': 123,
        'title': 'Test Collection',
        'ead_id': 'test-collection-123',
        'publish': True,
        'linked_agents': [
            {
                'role': 'creator',
                'ref': '/agents/corporate_entities/1'
            }
        ]
    }


@pytest.fixture
def sample_agent():
    """Sample agent (creator) data from ArchivesSpace API."""
    return {
        'uri': '/agents/corporate_entities/1',
        'id': 1,
        'title': 'Test Organization',
        'display_name': {
            'sort_name': 'Test Organization'
        },
        'is_user': False,
        'system_generated': False,
        'is_repo_agent': False,
        'linked_agent_roles': ['creator'],
        'is_linked_to_published_record': True,
        'notes': []
    }


@pytest.fixture
def sample_agent_with_bioghist():
    """Sample agent with biographical/historical note."""
    return {
        'uri': '/agents/people/42',
        'id': 42,
        'title': 'Jane Doe',
        'display_name': {
            'sort_name': 'Doe, Jane'
        },
        'is_user': False,
        'system_generated': False,
        'notes': [
            {
                'jsonmodel_type': 'note_bioghist',
                'persistent_id': 'abc123',
                'subnotes': [
                    {
                        'content': 'Jane Doe was a pioneering librarian.\nShe worked from 1950 to 1990.'
                    }
                ]
            }
        ]
    }


@pytest.fixture
def sample_ead_xml():
    """Sample EAD XML content for testing."""
    return b'''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9">
  <eadheader>
    <eadid>test.collection.123</eadid>
    <filedesc>
      <titlestmt>
        <titleproper>Test Collection</titleproper>
      </titlestmt>
    </filedesc>
  </eadheader>
  <archdesc level="collection">
    <did>
      <unittitle>Test Collection</unittitle>
      <unitid>test-collection-123</unitid>
    </did>
  </archdesc>
</ead>'''


@pytest.fixture
def sample_ead_xml_with_dots():
    """Sample EAD XML with dots in the eadid (should be converted to dashes)."""
    return b'''<?xml version="1.0" encoding="UTF-8"?>
<ead xmlns="urn:isbn:1-931666-22-9">
  <eadheader>
    <eadid>test.collection.with.dots</eadid>
  </eadheader>
</ead>'''


@pytest.fixture
def mock_subprocess_result():
    """Mock subprocess result for testing subprocess calls."""
    result = Mock()
    result.returncode = 0
    result.stdout = ''
    result.stderr = b''
    return result


@pytest.fixture
def sample_traject_config_content():
    """Sample traject configuration file content."""
    return """
# Traject configuration for EAC-CPF creator records
require 'traject'
require 'traject/xml_reader'

settings do
  provide "reader_class_name", "Traject::XmlReader"
  provide "solr.url", ENV['SOLR_URL']
end

to_field 'id', extract_xpath('/eac-cpf/control/recordId')
to_field 'title', extract_xpath('/eac-cpf/cpfDescription/identity/nameEntry/part')
to_field 'is_creator', literal('true')
"""
