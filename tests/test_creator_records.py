"""
Tests for fetching creator records from the aspace-eac-cpf-2 ArchivesSpace plugin.
"""

import os
import tempfile
import unittest
from unittest.mock import Mock, patch

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


class TestRunCreatorsPreflight(unittest.TestCase):
    """A failed check must leave existing creator records alone: deleting first
    and failing after left stage's Arclight with no creators at all."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.arcflow = make_arcflow()
        self.arcflow.arclight_dir = self.tmp.name
        self.arcflow.solr_url = 'http://solr.test/solr/blacklight-core'
        self.arcflow.force_update = True
        self.arcflow.skip_creator_indexing = False
        self.arcflow.process_creators = Mock()
        self.agents_dir = os.path.join(self.tmp.name, 'public', 'xml', 'agents')
        os.makedirs(self.agents_dir)
        with open(os.path.join(self.agents_dir, 'creator_people_1.xml'), 'w') as f:
            f.write(EAC_CPF_2)

    def tearDown(self):
        self.tmp.cleanup()

    def assert_left_alone(self, post):
        post.assert_not_called()
        self.arcflow.process_creators.assert_not_called()
        self.assertTrue(os.path.exists(os.path.join(self.agents_dir, 'creator_people_1.xml')))

    @patch('main.requests.post')
    def test_no_traject_config_deletes_nothing(self, post):
        self.arcflow.eac_cpf_plugin_installed = Mock(return_value=True)
        self.arcflow.find_eac_cpf_config = Mock(return_value=None)

        self.arcflow.run_creators(0, 1)

        self.assert_left_alone(post)

    @patch('main.requests.post')
    def test_missing_plugin_deletes_nothing(self, post):
        self.arcflow.eac_cpf_plugin_installed = Mock(return_value=False)

        self.arcflow.run_creators(0, 1)

        self.assert_left_alone(post)

    @patch('main.requests.post')
    def test_tears_down_and_processes_once_everything_is_ready(self, post):
        post.return_value = Mock(status_code=200)
        self.arcflow.eac_cpf_plugin_installed = Mock(return_value=True)
        self.arcflow.find_eac_cpf_config = Mock(return_value='/arcuit/lib/arcuit/traject/eac_cpf_config.rb')

        self.arcflow.run_creators(0, 1)

        post.assert_called_once()
        self.arcflow.process_creators.assert_called_once_with(1, 0)


class TestFindEacCpfConfig(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.arcflow = make_arcflow()
        self.arcflow.arclight_dir = self.tmp.name
        self.traject_dir = os.path.join(self.tmp.name, 'arcuit', 'lib', 'arcuit', 'traject')
        os.makedirs(self.traject_dir)
        self.config = os.path.join(self.traject_dir, 'eac_cpf_config.rb')

    def tearDown(self):
        self.tmp.cleanup()

    def bundle_shows_arcuit(self):
        return patch('main.subprocess.run', return_value=Mock(
            returncode=0, stdout=os.path.join(self.tmp.name, 'arcuit') + '\n', stderr=''))

    def write(self, name, text):
        with open(os.path.join(self.traject_dir, name), 'w') as f:
            f.write(text)

    def test_uses_an_arcuit_config_that_reads_eac_cpf_2(self):
        self.write('eac_cpf_config.rb', 'require_relative "eac_cpf"\n')
        self.write('eac_cpf.rb', 'NAMESPACES = { "eac" => "https://archivists.org/ns/eac/v2" }\n')

        with self.bundle_shows_arcuit():
            self.assertEqual(self.arcflow.find_eac_cpf_config(), self.config)

    def test_rejects_a_config_for_eac_cpf_2010(self):
        """Arcuit before #149, and arcflow's own example config, index 2.0
        records without error, but empty."""
        self.write('eac_cpf_config.rb', 'EAC_NS = { "eac" => "urn:isbn:1-931666-33-4" }\n')

        with self.bundle_shows_arcuit():
            self.assertIsNone(self.arcflow.find_eac_cpf_config())
        self.assertIn('does not read EAC-CPF 2.0', str(self.arcflow.log.critical.call_args_list))

    @patch('main.subprocess.run', side_effect=FileNotFoundError(2, 'No such file or directory', 'bundle'))
    def test_explains_a_missing_bundle_instead_of_crashing(self, _run):
        self.arcflow.find_eac_cpf_config()

        self.assertIn('`bundle` is not on the PATH', str(self.arcflow.log.critical.call_args_list))


if __name__ == '__main__':
    unittest.main()
