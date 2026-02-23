"""
Pytest configuration and shared fixtures
"""

import pytest


@pytest.fixture
def sample_eac_cpf_xml():
    """Sample EAC-CPF XML for testing"""
    return '''<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xmlns="urn:isbn:1-931666-33-4">
  <control>
    <recordId>test_creator</recordId>
    <maintenanceStatus>new</maintenanceStatus>
    <maintenanceAgency><agencyName>Test</agencyName></maintenanceAgency>
  </control>
  <cpfDescription>
    <identity>
      <nameEntry><part>Test Creator</part></nameEntry>
    </identity>
  </cpfDescription>
</eac-cpf>'''
