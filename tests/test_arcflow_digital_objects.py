"""
Tests for ArcFlow's handling of digital object MODS sidecars.
"""

import os
import tempfile
import unittest
from unittest.mock import Mock, patch

from main import ArcFlow


def make_arcflow(**attrs):
    """Build an ArcFlow without running __init__ (which reads config and logs in)."""
    arcflow = ArcFlow.__new__(ArcFlow)
    arcflow.log = Mock()
    arcflow.client = Mock()
    arcflow.digital_object_mods = Mock()
    for name, value in attrs.items():
        setattr(arcflow, name, value)
    return arcflow


class TestSaveDigitalObjectMods(unittest.TestCase):

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.xml_dir = self.tmp.name
        self.mods_file_path = f'{self.xml_dir}/digital_objects/UA.99.1.1.mods.xml'
        self.repo = {'uri': '/repositories/2'}
        self.resource = {'uri': '/repositories/2/resources/5'}
        self.arcflow = make_arcflow()

    def tearDown(self):
        self.tmp.cleanup()

    def write_previous_sidecar(self):
        os.makedirs(os.path.dirname(self.mods_file_path))
        with open(self.mods_file_path, 'wb') as file:
            file.write(b'<modsCollection/>')

    def test_get_mods_file_path(self):
        self.assertEqual(
            self.arcflow.get_mods_file_path('/x/public/xml/resources/UA.99.1.1.xml'),
            '/x/public/xml/resources/digital_objects/UA.99.1.1.mods.xml')

    def test_saves_sidecar(self):
        service = self.arcflow.digital_object_mods
        service.archival_object_uris_from_ead.return_value = ['/repositories/2/archival_objects/7']
        service.get_published_digital_objects.return_value = [({'uri': 'do'}, [])]
        service.build_mods_collection.return_value = b'<modsCollection>new</modsCollection>'

        self.assertTrue(self.arcflow.save_digital_object_mods(
            self.repo, self.resource, b'<ead/>', self.mods_file_path))

        service.archival_object_uris_from_ead.assert_called_once_with(b'<ead/>')
        service.get_published_digital_objects.assert_called_once_with(
            '/repositories/2', self.resource, ['/repositories/2/archival_objects/7'])
        service.build_mods_collection.assert_called_once_with(
            [({'uri': 'do'}, [])], '/repositories/2/resources/5')
        with open(self.mods_file_path, 'rb') as file:
            self.assertEqual(file.read(), b'<modsCollection>new</modsCollection>')

    def test_removes_sidecar_when_no_digital_objects(self):
        self.write_previous_sidecar()
        self.arcflow.digital_object_mods.build_mods_collection.return_value = None

        self.assertTrue(self.arcflow.save_digital_object_mods(
            self.repo, self.resource, b'<ead/>', self.mods_file_path))

        self.assertFalse(os.path.exists(self.mods_file_path))
        self.arcflow.log.error.assert_not_called()

    def test_no_sidecar_and_no_digital_objects(self):
        self.arcflow.digital_object_mods.build_mods_collection.return_value = None

        self.assertTrue(self.arcflow.save_digital_object_mods(
            self.repo, self.resource, b'<ead/>', self.mods_file_path))

        self.assertFalse(os.path.exists(os.path.dirname(self.mods_file_path)))
        self.arcflow.log.error.assert_not_called()

    def test_error_removes_previous_sidecar(self):
        self.write_previous_sidecar()
        self.arcflow.digital_object_mods.get_published_digital_objects.side_effect = RuntimeError('boom')

        self.assertTrue(self.arcflow.save_digital_object_mods(
            self.repo, self.resource, b'<ead/>', self.mods_file_path))

        self.assertFalse(os.path.exists(self.mods_file_path))
        self.arcflow.log.critical.assert_called_once()
        self.assertIn('/repositories/2/resources/5', self.arcflow.log.critical.call_args[0][0])


class TestDeleteEad(unittest.TestCase):

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.resource_dir = self.tmp.name
        self.arcflow = make_arcflow()
        self.arcflow.delete_arclight_solr_record = Mock(return_value=True)
        for name in ('UA.99.1.1.xml', 'UA.99.1.1.pdf'):
            open(f'{self.resource_dir}/{name}', 'w').close()
        os.symlink('UA.99.1.1.xml', f'{self.resource_dir}/5.xml')

    def tearDown(self):
        self.tmp.cleanup()

    def delete_ead(self):
        self.arcflow.delete_ead(
            5, 'UA-99-1-1',
            f'{self.resource_dir}/UA.99.1.1.xml',
            f'{self.resource_dir}/UA.99.1.1.pdf')

    def test_deletes_sidecar(self):
        os.makedirs(f'{self.resource_dir}/digital_objects')
        mods_file_path = f'{self.resource_dir}/digital_objects/UA.99.1.1.mods.xml'
        open(mods_file_path, 'w').close()

        self.delete_ead()

        self.assertFalse(os.path.exists(mods_file_path))
        self.assertEqual(os.listdir(self.resource_dir), ['digital_objects'])
        self.arcflow.log.error.assert_not_called()

    def test_without_sidecar(self):
        self.delete_ead()

        self.assertEqual(os.listdir(self.resource_dir), [])
        self.arcflow.log.error.assert_not_called()


class TestIndexCollections(unittest.TestCase):

    def test_passes_digital_objects_dir_to_traject(self):
        with tempfile.TemporaryDirectory() as resource_dir:
            open(f'{resource_dir}/UA.99.1.1.xml', 'w').close()
            os.symlink('UA.99.1.1.xml', f'{resource_dir}/created_2_5.xml')
            arcflow = make_arcflow(
                arclight_dir='/arclight', solr_url='http://solr/core',
                processing_thread_pool=1, solr_writer_thread_pool=1,
                collection_batch_size=100, ead_extra_config=None)

            with patch('main.subprocess.run') as run:
                run.return_value = Mock(returncode=0, stdout='/gems/arclight\n')
                self.assertTrue(arcflow.index_collections('2', resource_dir))

            traject_cmd = run.call_args_list[1][0][0]
            self.assertIn(
                f'arcuit.digital_objects_dir={resource_dir}/digital_objects', traject_cmd)
            self.assertEqual(
                traject_cmd[traject_cmd.index(f'arcuit.digital_objects_dir={resource_dir}/digital_objects') - 1], '-s')


if __name__ == '__main__':
    unittest.main()
