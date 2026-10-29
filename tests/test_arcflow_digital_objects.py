"""
Tests for ArcFlow's handling of digital object MODS sidecars.
"""

import os
import tempfile
import unittest
from multiprocessing.pool import ThreadPool
from unittest.mock import Mock, call, patch

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


class TestDeletedRecords(unittest.TestCase):

    def pages(self, *pages):
        responses = [
            Mock(**{'json.return_value': {'results': results, 'last_page': len(pages)}})
            for results in pages
        ]
        return Mock(side_effect=responses)

    def test_get_deleted_records_pages(self):
        arcflow = make_arcflow()
        arcflow.client.get = self.pages(['/repositories/2/digital_objects/1'], ['/agents/people/3'])

        self.assertEqual(
            list(arcflow.get_deleted_records(1700000000)),
            ['/repositories/2/digital_objects/1', '/agents/people/3'])
        self.assertEqual(
            [c.kwargs['params'] for c in arcflow.client.get.call_args_list],
            [{'page': 1, 'modified_since': 1700000000}, {'page': 2, 'modified_since': 1700000000}])
        for c in arcflow.client.get.call_args_list:
            self.assertEqual(c.args, ('/delete-feed-restricted',))

    def test_process_deleted_records_uses_feed(self):
        arcflow = make_arcflow(
            arclight_dir='/arclight', skip_deleted_record_processing=False, omeka=Mock())
        arcflow.client.get = self.pages(
            ['/repositories/2/digital_objects/1'], ['/agents/people/3'])
        arcflow.delete_creator = Mock()

        arcflow.process_deleted_records({'collections': 10, 'creators': 20, 'digital_objects': 5})

        arcflow.omeka.delete.assert_called_once_with('/repositories/2/digital_objects/1')
        arcflow.delete_creator.assert_called_once_with(
            '/arclight/public/xml/agents/3.xml', 'creator_people_3')
        self.assertEqual(arcflow.client.get.call_args_list[0].kwargs['params']['modified_since'], 5)


def json_response(data):
    return Mock(**{'json.return_value': data})


class TestDigitalObjectCollections(unittest.TestCase):

    def setUp(self):
        self.repo = {'uri': '/repositories/2'}
        self.arcflow = make_arcflow(skip_deleted_record_processing=False)

    def test_get_resource_ids_by_ead(self):
        with tempfile.TemporaryDirectory() as resource_dir:
            for name in ('UA.99.1.1.xml', 'MS.1.xml'):
                open(f'{resource_dir}/{name}', 'w').close()
            os.symlink('UA.99.1.1.xml', f'{resource_dir}/5.xml')
            os.symlink('MS.1.xml', f'{resource_dir}/12.xml')
            os.symlink('MS.1.xml', f'{resource_dir}/created_2_12.xml')
            os.symlink('gone.xml', f'{resource_dir}/40.xml')
            os.makedirs(f'{resource_dir}/digital_objects')

            self.assertEqual(
                self.arcflow.get_resource_ids_by_ead(resource_dir),
                {'UA.99.1.1': 5, 'MS.1': 12})

    def test_get_resource_ids_by_ead_without_dir(self):
        self.assertEqual(self.arcflow.get_resource_ids_by_ead('/nonexistent/resources'), {})

    def test_get_eads_with_digital_objects(self):
        self.arcflow._execute_solr_query = Mock(side_effect=[
            [{'ead_ssi': 'UA.99.1.1'}, {'ead_ssi': ['MS.1']}],
            [{'ead_ssi': 'UA.99.1.1'}, {}],
        ])
        uris = [f'/repositories/2/digital_objects/{i}' for i in range(1, 4)]

        self.assertEqual(
            self.arcflow.get_eads_with_digital_objects(uris + uris[:1], batch_size=2),
            {'UA.99.1.1', 'MS.1'})
        self.assertEqual(self.arcflow._execute_solr_query.call_args_list, [
            call(['digital_object_uri_ssi:("/repositories/2/digital_objects/1" OR "/repositories/2/digital_objects/2")'],
                 fields=['ead_ssi'], params={'defType': 'lucene'}),
            call(['digital_object_uri_ssi:("/repositories/2/digital_objects/3")'],
                 fields=['ead_ssi'], params={'defType': 'lucene'}),
        ])

    @patch('main.requests.get')
    def test_execute_solr_query_with_params(self, get):
        self.arcflow.solr_url = 'http://solr/arclight'
        count = Mock(json=Mock(return_value={'response': {'numFound': 1}}))
        data = Mock(json=Mock(return_value={'response': {'docs': [{'ead_ssi': 'MS.1'}]}}))
        get.side_effect = [count, data]

        docs = self.arcflow._execute_solr_query(
            ['digital_object_uri_ssi:("/repositories/2/digital_objects/1")'],
            fields=['ead_ssi'], params={'defType': 'lucene'})

        self.assertEqual(docs, [{'ead_ssi': 'MS.1'}])
        query = 'digital_object_uri_ssi:("/repositories/2/digital_objects/1")'
        self.assertEqual(get.call_args_list, [
            call('http://solr/arclight/select',
                 params={'q': query, 'rows': 0, 'wt': 'json', 'defType': 'lucene'}),
            call('http://solr/arclight/select',
                 params={'q': query, 'rows': 1, 'fl': 'ead_ssi', 'wt': 'json', 'defType': 'lucene'}),
        ])

    def test_get_eads_with_no_digital_objects(self):
        self.arcflow._execute_solr_query = Mock()

        self.assertEqual(self.arcflow.get_eads_with_digital_objects([]), set())
        self.arcflow._execute_solr_query.assert_not_called()

    def test_task_digital_object_collections(self):
        modified = [{'uri': '/repositories/2/digital_objects/8'}]
        self.arcflow.client.get.side_effect = [
            json_response([8, 9]),        # digital objects modified since
            json_response([5, 6, 7, 12]),  # resources that still exist
        ]
        service = self.arcflow.digital_object_mods
        service.fetch_by_ids.return_value = modified
        service.get_linked_resource_ids.return_value = {6}
        self.arcflow.get_eads_with_digital_objects = Mock(return_value={'UA.99.1.1', 'MS.1', 'Unknown.1'})

        resource_ids = self.arcflow.task_digital_object_collections(
            self.repo, 1700000000, ['/repositories/2/digital_objects/3'],
            {'UA.99.1.1': 5, 'MS.1': 40})

        # 40 was deleted from ArchivesSpace; Unknown.1 was never exported
        self.assertEqual(resource_ids, {5, 6})
        self.assertEqual(self.arcflow.client.get.call_args_list, [
            call('/repositories/2/digital_objects', params={'all_ids': True, 'modified_since': 1700000000}),
            call('/repositories/2/resources', params={'all_ids': True}),
        ])
        service.fetch_by_ids.assert_called_once_with('/repositories/2', 'digital_objects', [8, 9])
        service.get_linked_resource_ids.assert_called_once_with('/repositories/2', modified)
        # digital object 9 wasn't returned (e.g. suppressed) but is still looked up in Solr
        self.arcflow.get_eads_with_digital_objects.assert_called_once_with([
            '/repositories/2/digital_objects/8',
            '/repositories/2/digital_objects/9',
            '/repositories/2/digital_objects/3',
        ])
        self.arcflow.log.warning.assert_called_once()

    def test_task_digital_object_collections_without_changes(self):
        self.arcflow.client.get.return_value = json_response([])
        self.arcflow.digital_object_mods.fetch_by_ids.return_value = []
        self.arcflow.digital_object_mods.get_linked_resource_ids.return_value = set()
        self.arcflow.get_eads_with_digital_objects = Mock(return_value=set())

        self.assertEqual(
            self.arcflow.task_digital_object_collections(self.repo, 1700000000, [], {}), set())
        self.arcflow.client.get.assert_called_once()

    def test_add_digital_object_collections(self):
        repo_3 = {'uri': '/repositories/3'}
        self.arcflow.get_deleted_records = Mock(return_value=iter([
            '/repositories/2/digital_objects/1',
            '/repositories/2/resources/4',
            '/repositories/3/digital_objects/2',
            '/agents/people/3',
        ]))
        self.arcflow.get_resource_ids_by_ead = Mock(return_value={'UA.99.1.1': 5})
        self.arcflow.task_digital_object_collections = Mock(side_effect=[{5, 6}, set()])

        with ThreadPool(2) as pool:
            merged = self.arcflow.add_digital_object_collections(
                pool, [(self.repo, [6, 1]), (repo_3, [])], 1700000000, '/arclight/public/xml/resources')

        self.assertEqual(merged, [(self.repo, [6, 1, 5]), (repo_3, [])])
        self.arcflow.get_deleted_records.assert_called_once_with(1700000000)
        self.arcflow.get_resource_ids_by_ead.assert_called_once_with('/arclight/public/xml/resources')
        self.assertCountEqual(self.arcflow.task_digital_object_collections.call_args_list, [
            call(self.repo, 1700000000, ['/repositories/2/digital_objects/1'], {'UA.99.1.1': 5}),
            call(repo_3, 1700000000, ['/repositories/3/digital_objects/2'], {'UA.99.1.1': 5}),
        ])

    def test_add_digital_object_collections_skips_delete_feed(self):
        self.arcflow.skip_deleted_record_processing = True
        self.arcflow.get_deleted_records = Mock()
        self.arcflow.get_resource_ids_by_ead = Mock(return_value={})
        self.arcflow.task_digital_object_collections = Mock(return_value={5})

        with ThreadPool(1) as pool:
            merged = self.arcflow.add_digital_object_collections(
                pool, [(self.repo, [])], 1700000000, '/r')

        self.assertEqual(merged, [(self.repo, [5])])
        self.arcflow.get_deleted_records.assert_not_called()
        self.arcflow.task_digital_object_collections.assert_called_once_with(self.repo, 1700000000, [], {})


class TestProcessCollections(unittest.TestCase):

    def process_collections(self, modified_since, **attrs):
        repo = {'uri': '/repositories/2'}
        settings = dict(
            arclight_dir='/arclight', repository_id=None, skip_resource_processing=False,
            skip_collection_indexing=True, skip_pdf_generation=True)
        settings.update(attrs)
        arcflow = make_arcflow(**settings)
        arcflow.client.get.return_value = json_response([repo])
        arcflow.task_repository = Mock(return_value=(repo, [1]))
        arcflow.add_digital_object_collections = Mock(return_value=[(repo, [1, 5])])
        arcflow.task_resource = Mock()
        with patch('main.time.time', return_value=1800000000):
            arcflow.process_collections(2, modified_since)
        return arcflow

    def exported_resource_ids(self, arcflow):
        return sorted(c.args[1] for c in arcflow.task_resource.call_args_list)

    def test_adds_collections_with_changed_digital_objects(self):
        arcflow = self.process_collections(1700000000)

        arcflow.add_digital_object_collections.assert_called_once()
        self.assertEqual(arcflow.add_digital_object_collections.call_args.args[1:],
            ([({'uri': '/repositories/2'}, [1])], 1700000000, '/arclight/public/xml/resources'))
        self.assertEqual(self.exported_resource_ids(arcflow), [1, 5])
        self.assertEqual(int(arcflow.last_updated_collections.timestamp()), 1800000000)

    def test_full_export_doesnt_look_up_digital_objects(self):
        arcflow = self.process_collections(0)

        arcflow.add_digital_object_collections.assert_not_called()
        self.assertEqual(self.exported_resource_ids(arcflow), [1])

    def test_skip_resource_processing(self):
        arcflow = self.process_collections(1700000000, skip_resource_processing=True)

        arcflow.add_digital_object_collections.assert_not_called()
        arcflow.task_resource.assert_not_called()


if __name__ == '__main__':
    unittest.main()
