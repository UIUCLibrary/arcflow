"""
Test configuration and shared fixtures for arcflow test suite.
"""
import pytest


@pytest.fixture
def sample_eac_cpf_xml():
    """Minimal valid EAC-CPF XML for testing"""
    return '''<?xml version="1.0" encoding="UTF-8"?>
<eac-cpf xmlns="urn:isbn:1-931666-33-4">
  <control>
    <recordId>creator_people_1</recordId>
    <maintenanceStatus>new</maintenanceStatus>
    <maintenanceAgency>
      <agencyName>Test</agencyName>
    </maintenanceAgency>
  </control>
  <cpfDescription>
    <identity>
      <nameEntry>
        <part>Test Person</part>
      </nameEntry>
    </identity>
  </cpfDescription>
</eac-cpf>'''
