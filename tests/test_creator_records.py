"""
Tests for fetching creator records from the aspace-eac-cpf-2 ArchivesSpace plugin.
"""

import os
import tempfile
import unittest
from unittest.mock import Mock

from main import ArcFlow
from services.xml_transform_service import XmlTransformService

EAC_CPF_2 = '''<?xml version="1.0" encoding="UTF-8"?>
<eac xmlns="https://archivists.org/ns/eac/v2"><control maintenanceStatus="new"/></eac>'''


def response(status, text='', error=None):
    resp = Mock(status_code=status, text=text)
    if error is None:
        resp.json.side_effect = ValueError('not JSON')
    else:
        resp.json.return_value = {'error': error}
    return resp


def make_arcflow():
    """Build an ArcFlow without running __init__ (which reads config and logs in)."""
    arcflow = ArcFlow.__new__(ArcFlow)
    arcflow.log = Mock()
    arcflow.client = Mock()
    arcflow.xml_transform = XmlTransformService(log=arcflow.log)
    arcflow.delete_creator = Mock()
    return arcflow


class TestTaskAgent(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.agents_dir = self.tmp.name
        self.arcflow = make_arcflow()

    def tearDown(self):
        self.tmp.cleanup()

    def test_fetches_eac_cpf_2_from_the_plugin_and_saves_it_unchanged(self):
        self.arcflow.client.get.return_value = response(200, EAC_CPF_2)

        creator_id = self.arcflow.task_agent('/agents/corporate_entities/1338', self.agents_dir)

        self.assertEqual(creator_id, 'creator_corporate_entities_1338')
        self.arcflow.client.get.assert_called_once_with('/agents/corporate_entities/1338/eac_cpf_2.xml')
        with open(os.path.join(self.agents_dir, 'creator_corporate_entities_1338.xml'), encoding='utf-8') as f:
            self.assertEqual(f.read(), EAC_CPF_2)

    def test_removes_the_creator_record_of_an_unpublished_agent(self):
        self.arcflow.client.get.return_value = response(404, error='Agent not published')

        self.assertIsNone(self.arcflow.task_agent('/agents/people/3015', self.agents_dir))

        self.arcflow.delete_creator.assert_called_once_with(
            f'{self.agents_dir}/creator_people_3015.xml', 'creator_people_3015')

    def test_never_deletes_because_the_plugin_is_missing(self):
        """Without the plugin every agent is a 404; that must not empty the index."""
        self.arcflow.client.get.return_value = response(404, error='Sinatra::NotFound')

        self.assertIsNone(self.arcflow.task_agent('/agents/people/3015', self.agents_dir))

        self.arcflow.delete_creator.assert_not_called()


class TestPluginCheck(unittest.TestCase):
    def test_plugin_is_installed_when_ArchivesSpace_knows_the_route(self):
        arcflow = make_arcflow()
        arcflow.client.get.return_value = response(404, error='AgentPerson not found')

        self.assertTrue(arcflow.eac_cpf_plugin_installed())
        arcflow.client.get.assert_called_once_with('/agents/people/0/eac_cpf_2.xml')

    def test_plugin_is_missing_when_ArchivesSpace_has_no_such_route(self):
        arcflow = make_arcflow()
        arcflow.client.get.return_value = response(404, error='Sinatra::NotFound')

        self.assertFalse(arcflow.eac_cpf_plugin_installed())
        arcflow.log.critical.assert_called_once()


if __name__ == '__main__':
    unittest.main()
