import os
import shutil
import argparse
import json
import yaml
import time
import requests
import subprocess
import re
import logging
import math
from xml.dom.pulldom import parse, START_ELEMENT
from datetime import datetime, timezone
from asnake.client import ASnakeClient
from utils.omeka import OmekaClient
from multiprocessing.pool import ThreadPool as Pool
from utils.stage_classifications import extract_labels


base_dir = os.path.abspath((__file__) + "/../../")
log_file = os.path.join(base_dir, 'logs/arcflow.log')
os.makedirs(os.path.dirname(log_file), mode=0o755, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname).1s - %(asctime)s - %(message)s',
    datefmt='%Y-%m-%dT%H:%M:%S%z',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(log_file),
    ]
)


class ArcFlow:
    """
    ArcFlow is a class that represents a flow of data from ArchivesSpace 
    to ArcLight.
    """


    def __init__(
            self,
            arclight_dir,
            aspace_dir,
            solr_url,
            traject_extra_config='',
            include_digital_objects=False,
            force_update=False,
            dry_run_aspace=False):
        self.solr_url = solr_url
        self.batch_size = 1000
        self.traject_extra_config = f'-c {traject_extra_config}' if traject_extra_config.strip() else ''
        self.arclight_dir = arclight_dir
        self.aspace_jobs_dir = f'{aspace_dir}/data/shared/job_files'
        self.job_type = 'print_to_pdf_job'
        self.include_digital_objects = include_digital_objects
        self.force_update = force_update
        self.dry_run_aspace = dry_run_aspace
        self.log = logging.getLogger('arcflow')
        self.pid = os.getpid()
        self.pid_file_path = os.path.join(base_dir, 'arcflow.pid')
        self.arcflow_file_path = os.path.join(base_dir, '.arcflow.yml')
        self.omeka_file_path = os.path.join(base_dir, '.omeka.yml')
        if self.is_running():
            self.log.info(f'ArcFlow process previously started still running. Exiting (PID: {self.pid}).')
            exit(0)
        else:
            self.create_pid_file()

        self.start_time = int(time.time())
        try:
            with open(self.arcflow_file_path, 'r') as file:
                config = yaml.safe_load(file)
            try:
                self.repositories_last_updated = datetime.strptime(
                    config['repositories_last_updated'], '%Y-%m-%dT%H:%M:%S%z')
                self.resources_last_updated = datetime.strptime(
                    config['resources_last_updated'], '%Y-%m-%dT%H:%M:%S%z')
                self.digital_objects_last_updated = datetime.strptime(
                    config['digital_objects_last_updated'], '%Y-%m-%dT%H:%M:%S%z')
            except Exception as e:
                self.log.error(f'Error parsing dates on file .arcflow.yml: {e}')
                exit(0)
        except FileNotFoundError:
            if not self.force_update:
                self.log.error('File .arcflow.yml not found. Create the file and try again or run with --force-update to recreate EADs from scratch.')
                exit(0)
            else:
                self.repositories_last_updated = datetime.fromtimestamp(0, timezone.utc)
                self.resources_last_updated = datetime.fromtimestamp(0, timezone.utc)
                self.digital_objects_last_updated = datetime.fromtimestamp(0, timezone.utc)

        try:
            with open(os.path.join(base_dir, '.archivessnake.yml'), 'r') as file:
                config = yaml.safe_load(file)
        except FileNotFoundError:
            self.log.error('File .archivessnake.yml not found. Create the file.')
            exit(0)
        try:
            self.client = ASnakeClient(
                username=config['username'],
                password=config['password'],
                baseurl=config['baseurl'],
            )
            self.client.authorize()
        except Exception as e:
            self.log.error(f'Error authorizing ASnakeClient: {e}')
            exit(0)

        try:
            with open(self.omeka_file_path, 'r') as file:
                config = yaml.safe_load(file)
                self.use_archon = config.get('use_archon', 0)
        except FileNotFoundError:
            self.log.error('File .omeka.yml not found. Create the file.')
            exit(0)
        try:
            self.omeka = OmekaClient(
                **config,
                logger=self.log,
                asnake_client = self.client,
                dry_run_aspace = self.dry_run_aspace,
            )
        except Exception as e:
            self.log.error(f'Error initializing OmekaClient: {e}')
            exit(0)


    def is_running(self):
        """
        Check if the ArcFlow process is already running.
        """
        if os.path.isfile(self.pid_file_path):
            with open(self.pid_file_path, 'r') as file:
                pid = int(file.read().strip())
            try:
                os.kill(pid, 0)
                return True
            except OSError:
                pass
        return False


    def create_pid_file(self):
        """
        Create a PID file to indicate that the ArcFlow process is running.
        """
        with open(self.pid_file_path, 'w') as file:
            file.write(str(self.pid))


    def update_repositories(self):
        """
        Update the repositories.yml file with the latest data from ArchivesSpace.
        """
        repos_file_path = f'{self.arclight_dir}/config/repositories.yml'
        repos = self.client.get('repositories').json()

        if self.force_update:
            update_repos = True
        else:
            self.log.info('Checking for updates on repositories information...')

            update_repos = False
            for repo in repos:
                # python doesn't support Zulu timezone suffixes, 
                # converting system_mtime and user_mtime to UTC offset notation
                if (self.repositories_last_updated <= datetime.strptime(
                        repo['system_mtime'].replace('Z','+0000'),
                        '%Y-%m-%dT%H:%M:%S%z')
                        or self.repositories_last_updated <= datetime.strptime(
                        repo['user_mtime'].replace('Z','+0000'),
                        '%Y-%m-%dT%H:%M:%S%z')):
                    update_repos = True
                    break

        if update_repos:
            self.repositories_last_updated = datetime.fromtimestamp(int(time.time()), timezone.utc)
            with open(repos_file_path, 'w') as file:
                self.log.info(f'Updating file {repos_file_path}...')
                for repo in repos:
                    if repo['publish']:
                        agent_representation = self.client.get(
                            repo['agent_representation']['ref']).json()

                        contact = agent_representation['agent_contacts'][0]

                        telephones = [
                            f'<div class="al-repository-contact-{x["number_type"]}">{x["number"]}</div>'
                            for x in contact['telephones']
                        ]
                        repo['contact_html'] = telephones
                        if 'email' in contact:
                            repo['contact_html'].append(
                                f'<div class="al-repository-contact-info"><a href="mailto:{contact["email"]}">{contact["email"]}</a></div>'
                            )
                        repo['contact_html'] = ''.join(repo['contact_html'])

                        city_state_zip_country = []
                        for x in ('city', 'region', 'country'):
                            if x in contact:
                                if x == 'region' and 'post_code' in contact:
                                    city_state_zip_country.append(
                                        f'{contact[x]} {contact["post_code"]}')
                                else:
                                    city_state_zip_country.append(f'{contact[x]}')

                        repo['location_html'] = []
                        if 'address_1' in contact:
                            repo['location_html'].append(
                                f'<div class="al-repository-street-address-building">{contact["address_1"]}</div>')
                        if 'address_2' in contact:
                            repo['location_html'].append(
                                f'<div class="al-repository-street-address-address1">{contact["address_2"]}</div>')
                        if city_state_zip_country:
                            repo['location_html'].append(
                                f'<div class="al-repository-street-address-city_state_zip_country">{", ".join(city_state_zip_country)}</div>')
                        repo['location_html'] = ''.join(repo['location_html'])

                        if 'image_url' in repo:
                            repo['thumbnail_url'] = repo['image_url']

                        yaml.safe_dump({
                            self.get_repo_id(repo): {
                                k:repo[k] if k in repo else "" 
                                for k in (
                                    'name',
                                    'description',
                                    'contact_html',
                                    'location_html',
                                    'thumbnail_url',
                                    # 'request_types',
                                )
                            },
                        }, file, width=float('inf'))
        else:
            self.log.info(f'File {repos_file_path} is up to date.')


    def task_digital_object(self, repo, digital_object_id, indent_size=0):
        # TODO: for testing
        if digital_object_id not in (235, 75): #(3503,) (3501, 3502, 3503):
            return
        indent = ' ' * indent_size
        digital_object = self.client.get(
            f'{repo["uri"]}/digital_objects/{digital_object_id}',
            params={
                'resolve': [
                    'linked_agents',
                    'subjects',
                    'collection',
                    'repository',
                    'tree',
                ],
            }).json()

        self.log.info(f'{indent}Processing digital object ID {digital_object_id}...')
        omeka_uri = self.omeka.upsert(digital_object, indent_size=indent_size)
        self.log.info(f'{indent}Omeka item for digital object ID {digital_object_id}: {omeka_uri}.')


    def task_resource(self, repo, resource_id, xml_dir, pdf_dir, indent_size=0):
        # TODO: for testing
        if resource_id not in (284,):
            return (None, None, None)
        indent = ' ' * indent_size
        pdf_job = (None, None, None)
        resource = self.client.get(
            f'{repo["uri"]}/resources/{resource_id}',
            params={
                'resolve': ['classifications', 'classification_terms'],
            }).json()

        xml_file_path = f'{xml_dir}/{resource["ead_id"]}.xml'

        # replace dots with dashes in EAD ID to avoid issues with Solr
        ead_id = resource['ead_id'].replace('.', '-')
        self.log.info(f'{indent}Processing "{ead_id}" (resource ID {resource_id})...')

        if resource['publish'] and not resource['suppressed']:
            xml = self.client.get(
                f'{repo["uri"]}/resource_descriptions/{resource_id}.xml',
                params={
                    'include_unpublished': 'false',
                    'include_daos': 'true',
                    'include_uris': 'true',
                    'numbered_cs': 'true',
                    'ead3': 'false',
                })

            # add record group and subgroup labels to EAD inside <archdesc level="collection">
            if xml.content:
                rg_label, sg_label = extract_labels(resource)[1:3]
                if rg_label:
                    xml_content = xml.content.decode('utf-8')
                    insert_pos = xml_content.find('<archdesc level="collection">')
                    if insert_pos != -1:
                        # Find the position after the opening tag
                        insert_pos = xml_content.find('</did>', insert_pos)
                        extra_xml = f'<recordgroup>{rg_label}</recordgroup>'
                        if sg_label:
                            extra_xml += f'<subgroup>{sg_label}</subgroup>'
                        xml_content = (xml_content[:insert_pos] + 
                            extra_xml + 
                            xml_content[insert_pos:])
                    xml_content = xml_content.encode('utf-8')
                else:
                    xml_content = xml.content

            # next level of indentation for nested operations
            indent_size += 2

            if not self.dry_run_aspace:
                pdf_job = (repo['uri'], self.request_pdf_job(repo['uri'], resource_id, indent_size=indent_size), resource['ead_id'])

            # if the EAD ID was updated in ArchivesSpace,
            # delete the previous EAD in ArcLight Solr
            prev_ead_id = self.get_ead_from_symlink(
                f'{xml_dir}/{resource_id}.xml')
            if (prev_ead_id is not None 
                    and prev_ead_id != resource['ead_id']):
                self.delete_ead(
                    resource_id, 
                    prev_ead_id.replace('.', '-'),  # dashes in Solr
                    f'{xml_dir}/{prev_ead_id}.xml', # dots in filenames
                    f'{pdf_dir}/{prev_ead_id}.pdf', 
                    indent_size=indent_size)

            self.save_file(xml_file_path, xml_content, 'XML', indent_size=indent_size)
            self.create_symlink(
                os.path.basename(xml_file_path),
                f'{os.path.dirname(xml_file_path)}/{resource_id}.xml',
                indent_size=indent_size)

            repo_id = self.get_repo_id(repo)
            self.resources_counter[repo_id] += 1
            # files pending to index are named repoID_resourceID_batch_batchNUM.xml 
            self.create_symlink(
                os.path.basename(xml_file_path),
                f'{os.path.dirname(xml_file_path)}/{repo_id}_{resource_id}_batch_{math.ceil(self.resources_counter[repo_id]/self.batch_size)}.xml',
                indent_size=indent_size)
        else:
            self.delete_ead(
                resource_id, 
                ead_id, 
                xml_file_path, 
                f'{pdf_dir}/{resource["ead_id"]}.pdf', 
                indent_size=indent_size)

        # return the PDF job info for next async processing step
        return pdf_job

    def get_digital_objects_from_children(self, repo, modified_since):
        """
        Get the digital objects IDs from the digital object components that have been
        modified since last update in ArchivesSpace.
        """
        digital_objects = set()
        page = 1
        while True:
            digital_object_components = self.client.get(
                f'{repo["uri"]}/digital_object_components',
                params={
                    'page': page,
                    'modified_since': modified_since,
                }
            ).json()

            for digital_object_component in digital_object_components['results']:
                if 'digital_object' in digital_object_component and digital_object_component['digital_object'] is not None:
                    digital_object_id = int(digital_object_component['digital_object']['ref'].split('/')[-1])
                    digital_objects.add(digital_object_id)

            if digital_object_components['last_page'] == page:
                break
            page += 1

        return digital_objects


    def task_repository(self, repo, modified_since, object_type='resources', indent_size=0):
        indent = ' ' * indent_size
        object_list = self.client.get(f'{repo["uri"]}/{object_type}',
            params={
                'all_ids': True,
                'modified_since': modified_since,
            }
        ).json()
        repo_id = self.get_repo_id(repo)
        if object_type == 'resources':
            self.resources_counter[repo_id] = 0
        else:
            # suppressed/deleted digital objects components don't update its
            # parent digital object, so we need to check to get the full list of
            # digital objects that need to be processed
            digital_objects_from_children = self.get_digital_objects_from_children(repo, modified_since)
            object_list = list(set(object_list) | digital_objects_from_children)

        self.log.info(f'{indent}Found {len(object_list)} {object_type} in repository ID {repo_id}.')

        # return the repository and its objects (resources or digital objects)
        # for next async processing step
        return (repo, object_list)


    def task_pdf(self, repo_uri, job_id, ead_id, pdf_dir, indent_size=0):
        indent = ' ' * indent_size
        while True:
            job_status = self.client.get(
                f'{repo_uri}/jobs/{job_id}').json()['status']

            if job_status in ('completed', 'canceled', 'failed'):
                if job_status == 'completed':
                    file_id = self.client.get(
                        f'{repo_uri}/jobs/{job_id}/output_files').json()[0]

                    pdf = self.client.get(
                        f'{repo_uri}/jobs/{job_id}/output_files/{file_id}')
                elif job_status in ('canceled', 'failed'):
                    self.log.error(f'{indent}ArchivesSpace {self.job_type}_{job_id} {job_status}.')
                    pdf = None

                # not deleting to avoid cluttering the delete feed with deleted jobs
                # # delete to avoid accumulation of jobs in ArchivesSpace
                # response = self.client.delete(f'{repo_uri}/jobs/{job_id}')
                # if response.status_code == 200:
                #     job_dir = f'{self.aspace_jobs_dir}/{self.job_type}_{job_id}'
                #     # delete physical job directory
                #     try:
                #         shutil.rmtree(job_dir)
                #     except Exception as e:
                #         self.log.error(f'{indent}Error deleting ArchivesSpace directory "{job_dir}": {e}')
                # else:
                #     self.log.error(f'{indent}Failed to delete ArchivesSpace {self.job_type}_{job_id}. Status code: {response.status_code}')

                if hasattr(pdf, 'content'):
                    pdf_content = pdf.content
                else:
                    pdf_content = b''   # empty PDF file

                self.save_file(
                    f'{pdf_dir}/{ead_id}.pdf', 
                    pdf_content, 
                    'PDF', 
                    indent_size=indent_size)

                self.log.info(f'Finished processing "{ead_id}".')
                return True

            self.log.info(f'{indent}Waiting for ArchivesSpace {self.job_type}_{job_id} to complete... (current status: {job_status})')
            time.sleep(5)


    def update_eads(self):
        """
        Update EADs in ArcLight with the latest data from resources in 
        ArchivesSpace.
        """
        indent_size = 2

        xml_dir = f'{self.arclight_dir}/public/xml'
        pdf_dir = f'{self.arclight_dir}/public/pdf'

        resources_modified_since = int(self.resources_last_updated.timestamp())
        digital_objects_modified_since = 0
        if self.force_update or resources_modified_since <= 0:
            resources_modified_since = 0
            # delete all EADs and related files in ArcLight Solr
            try:
                response = requests.post(
                    f'{self.solr_url}/update?commit=true',
                    json={'delete': {'query': '*:*'}},
                )
                if response.status_code == 200:
                    self.log.info('Deleted all EADs from ArcLight Solr.')
                    # delete related directories after suscessful
                    # deletion from solr
                    for dir_path, dir_name in [(xml_dir, 'XMLs'), (pdf_dir, 'PDFs')]:
                        try:
                            shutil.rmtree(dir_path)
                            self.log.info(f'Deleted {dir_name} directory {dir_path}.')
                        except Exception as e:
                            self.log.error(f'Error deleting {dir_name} directory "{dir_path}": {e}')
                else:
                    self.log.error(f'Failed to delete all EADs from Arclight Solr. Status code: {response.status_code}')
            except requests.exceptions.RequestException as e:
                self.log.error(f'Error deleting all EADs from ArcLight Solr: {e}')

        if self.include_digital_objects:
            digital_objects_modified_since = int(self.digital_objects_last_updated.timestamp())
            if self.force_update or digital_objects_modified_since <= 0:
                digital_objects_modified_since = 0
                self.log.info('Deleting all digital objects from Omeka...')
                self.omeka.delete_all(indent_size)

        # create directories if don't exist
        for dir_path in (xml_dir, pdf_dir):
            os.makedirs(dir_path, exist_ok=True)

        # process resources and/or digital objects that have been
        # modified in ArchivesSpace since last update
        processing_types = ['resources']
        if self.include_digital_objects:
            processing_types.append('digital objects')
        processing_types = ' and '.join(processing_types)
        self.log.info(f'Fetching {processing_types} from ArchivesSpace...')
        repos = self.client.get('repositories').json()

        self.resources_counter = {}
        with Pool(processes=10) as pool:

            if self.include_digital_objects:
                self.digital_objects_last_updated = datetime.fromtimestamp(int(time.time()), timezone.utc)
                # Tasks for processing repositories for digital objects
                results_repo_digital_objects = [pool.apply_async(
                    self.task_repository,
                    args=(repo, digital_objects_modified_since, 'digital_objects', indent_size)) 
                    for repo in repos if self.get_repo_id(repo) == '2'] #TODO: remove filter
                # Collect outputs from repository tasks for digital objects
                outputs_repo_digital_objects = [r.get() for r in results_repo_digital_objects]

                # Tasks for processing digital objects
                results_digital_objects = [pool.apply_async(
                    self.task_digital_object, 
                    args=(repo, digital_object_id, indent_size)) 
                    for repo, digital_objects in outputs_repo_digital_objects for digital_object_id in digital_objects]
                # Wait for digital objects tasks to complete
                for r in results_digital_objects:
                    r.get()

            self.resources_last_updated = datetime.fromtimestamp(int(time.time()), timezone.utc)
            # Tasks for processing repositories for resources
            results_repo_resources = [pool.apply_async(
                self.task_repository, 
                args=(repo, resources_modified_since, 'resources', indent_size)) 
                for repo in repos if self.get_repo_id(repo) == '2'] #TODO: remove filter
            # Collect outputs from repository tasks for resources
            outputs_repo_resources = [r.get() for r in results_repo_resources]

            # Tasks for processing resources
            results_resources = [pool.apply_async(
                self.task_resource, 
                args=(repo, resource_id, xml_dir, pdf_dir, indent_size)) 
                for repo, resources in outputs_repo_resources for resource_id in resources]
            # Collect outputs from resource tasks
            outputs_resources = [r.get() for r in results_resources]

            # Create batches for indexing pending resources
            batches = []
            for repo, resources in self.resources_counter.items():
                num_batches = math.ceil(resources/self.batch_size)
                for batch_num in range(1, num_batches + 1):
                    batches.append((repo, batch_num))
            # Tasks for indexing pending resources
            results_index = [pool.apply_async(
                self.index,
                args=(repo_id, f'{xml_dir}/{repo_id}_*_batch_{batch_num}.xml', indent_size))
                for repo_id, batch_num in batches]
            # Wait for indexing tasks to complete
            for r in results_index:
                r.get()
            # Remove pending symlinks after indexing
            for repo_id, batch_num in batches:
                xml_file_path = f'{xml_dir}/{repo_id}_*_batch_{batch_num}.xml'
                try:
                    result = subprocess.run(
                        f'rm {xml_file_path}',
                        shell=True,
                        cwd=self.arclight_dir,
                        stderr=subprocess.PIPE,)
                    self.log.error(f'{" " * indent_size}{result.stderr.decode("utf-8")}')
                    if result.returncode != 0:
                        self.log.error(f'{" " * indent_size}Failed to remove pending symlinks {xml_file_path}. Return code: {result.returncode}')
                except Exception as e:
                    self.log.error(f'{" " * indent_size}Error removing pending symlinks {xml_file_path}: {e}')

            # Tasks for processing PDFs
            results_pdf = [pool.apply_async(
                self.task_pdf,
                args=(repo_uri, job_id, ead_id, pdf_dir, indent_size))
                for repo_uri, job_id, ead_id in outputs_resources if job_id is not None]
            # Wait for PDF tasks to complete
            for r in results_pdf:
                r.get()

        # processing deleted resources or digital objects is not needed when
        # force-update is set or their modified_since is set to 0
        if self.force_update or (resources_modified_since <= 0 and
                digital_objects_modified_since <= 0):
            self.log.info(f'Skipping deleted {processing_types} processing.')
            return

        modified_since = min(resources_modified_since, digital_objects_modified_since)
        if digital_objects_modified_since <= 0:
            processing_types = 'resources'
            modified_since = resources_modified_since
        if resources_modified_since <= 0:
            processing_types = 'digital_objects'
            modified_since = digital_objects_modified_since

        # process resources or digital objects that have been deleted
        # since last update in ArchivesSpace
        pattern = rf'^/repositories/(?P<repo_id>\d+)/(?P<object_type>{processing_types.replace(" and ", "|").replace(" ", "_")})/(?P<object_id>\d+)$'
        page = 1
        while True:
            deleted_records = self.client.get(
                f'/delete-feed',
                params={
                    'page': page,
                    'modified_since': modified_since,
                }
            ).json()
            for record in deleted_records['results']:
                match = re.match(pattern, record)
                if match:
                    object_id = match.group('object_id')
                    object_type = match.group('object_type')
                    self.log.info(f'{" " * indent_size}Processing deleted {object_type[:-1]} ID {object_id}...')

                    if object_type == 'resources':
                        symlink_path = f'{xml_dir}/{object_id}.xml'
                        ead_id = self.get_ead_from_symlink(symlink_path)
                        if ead_id:
                            self.delete_ead(
                                object_id, 
                                ead_id.replace('.', '-'),  # dashes in Solr
                                f'{xml_dir}/{ead_id}.xml', # dots in filenames
                                f'{pdf_dir}/{ead_id}.pdf', 
                                indent=4)
                        else:
                            self.log.error(f'{" " * (indent_size+2)}Symlink {symlink_path} not found. Unable to delete the associated EAD from Arclight Solr.')
                    else:
                        self.omeka.delete(record)

            if deleted_records['last_page'] == page:
                break
            page += 1


    def index(self, repo_id, xml_file_path, indent_size=0):
        indent = ' ' * indent_size
        self.log.info(f'{indent}Indexing pending resources in repository ID {repo_id} to ArcLight Solr...')
        try:
            result = subprocess.run(
                f'REPOSITORY_ID={repo_id} bundle exec traject -u {self.solr_url} -s processing_thread_pool=8 -s solr_writer.thread_pool=8 -s solr_writer.batch_size={self.batch_size} -s solr_writer.commit_on_close=true -i xml -c $(bundle show arclight)/lib/arclight/traject/ead2_config.rb {self.traject_extra_config} {xml_file_path}',
#                f'FILE={xml_file_path} SOLR_URL={self.solr_url} REPOSITORY_ID={repo_id}  TRAJECT_SETTINGS="processing_thread_pool=8 solr_writer.thread_pool=8 solr_writer.batch_size=1000 solr_writer.commit_on_close=false" bundle exec rake arcuit:index',
                shell=True,
                cwd=self.arclight_dir,
                stderr=subprocess.PIPE,)
            self.log.error(f'{indent}{result.stderr.decode("utf-8")}')
            if result.returncode != 0:
                self.log.error(f'{indent}Failed to index pending resources in repository ID {repo_id} to ArcLight Solr. Return code: {result.returncode}')
            else:
                self.log.info(f'{indent}Finished indexing pending resources in repository ID {repo_id} to ArcLight Solr.')
        except subprocess.CalledProcessError as e:
            self.log.error(f'{indent}Error indexing pending resources in repository ID {repo_id} to ArcLight Solr: {e}')


    def get_repo_id(self, repo):
        """
        Get the repository ID from the repository URI.
        """
        return repo['uri'].split('/')[-1]


    def get_ead_id_from_file(self, xml_file_path):
        """
        Get the EAD ID from the XML file.
        """
        ead_id = None
        # parse the file to get the ead_id
        if os.path.isfile(xml_file_path):
            ead = parse(xml_file_path)
            for event, node in ead:
                if event == START_ELEMENT and node.tagName == 'eadid':
                    ead.expandNode(node)
                    ead_id = node.firstChild.nodeValue
                    break

        return ead_id


    def get_ead_from_symlink(self, symlink_path):
        """
        Get the EAD ID from the symlink file.
        """
        ead_id = None
        if os.path.isfile(symlink_path):
            real_path = os.path.realpath(symlink_path)
            ead_id = os.path.splitext(os.path.basename(real_path))[0]

        return ead_id


    def request_pdf_job(self, repo_uri, resource_id, indent_size=0):
        indent = ' ' * indent_size

        job = self.client.post(
            f'{repo_uri}/jobs',
            json={
                'job': {
                    'source': f'{repo_uri}/resources/{resource_id}',
                    'jsonmodel_type': self.job_type,
                    'job_type': self.job_type,
                    'include_unpublished': False,
                }
            }
        ).json()
        self.log.info(f'{indent}{job["status"]} ArchivesSpace {self.job_type}_{job["id"]} for resource ID {resource_id}.')
        return job["id"]


    def save_file(self, file_path, content, label, indent_size=0):
        indent = ' ' * indent_size
        try:
            with open(file_path, 'wb') as file:
                file.write(content)
                self.log.info(f'{indent}Saved {label} file {file_path}.')
                return True
        except Exception as e:
            self.log.error(f'{indent}Error writing to {label} file {file_path}: {e}')
            return False


    def create_symlink(self, target_path, symlink_path, indent_size=0):
        indent = ' ' * indent_size
        try:
            os.symlink(target_path, symlink_path)
            self.log.info(f'{indent}Created symlink {symlink_path} -> {target_path}.')
            return True
        except FileExistsError as e:
            self.log.info(f'{indent}{e}')
            return False


    def delete_ead(self, resource_id, ead_id, 
            xml_file_path, pdf_file_path, indent_size=0):
        indent = ' ' * indent_size
        # delete from solr
        try:
            response = requests.post(
                f'{self.solr_url}/update?commit=true',
                json={'delete': {'id': ead_id}},
            )
            if response.status_code == 200:
                self.log.info(f'{indent}Deleted EAD "{ead_id}" from ArcLight Solr.')
                # delete related files after suscessful deletion from solr
                for file_path in (xml_file_path, pdf_file_path):
                    try:
                        os.remove(file_path)
                        self.log.info(f'{indent}Deleted file {file_path}.')
                    except FileNotFoundError:
                        self.log.error(f'{indent}File {file_path} not found.')

                # delete symlink if exists
                symlink_path = f'{os.path.dirname(xml_file_path)}/{resource_id}.xml'
                try:
                    os.remove(symlink_path)
                    self.log.info(f'{indent}Deleted symlink {symlink_path}.')
                except FileNotFoundError:
                    self.log.info(f'{indent}Symlink {symlink_path} not found.')
            else:
                self.log.error(f'{indent}Failed to delete EAD "{ead_id}" from Arclight Solr. Status code: {response.status_code}')
        except requests.exceptions.RequestException as e:
            self.log.error(f'{indent}Error deleting EAD "{ead_id}" from ArcLight Solr: {e}')


    def save_config_files(self):
        """
        Save the last updated timestamp to the .arcflow.yml file.
        """
        try:
            with open(self.arcflow_file_path, 'w') as file:
                yaml.dump({
                    'repositories_last_updated': self.repositories_last_updated.strftime('%Y-%m-%dT%H:%M:%S%z'),
                    'resources_last_updated': self.resources_last_updated.strftime('%Y-%m-%dT%H:%M:%S%z'),
                    'digital_objects_last_updated': self.digital_objects_last_updated.strftime('%Y-%m-%dT%H:%M:%S%z'),
                }, file)
                self.log.info(f'Saved file .arcflow.yml.')
        except Exception as e:
            self.log.error(f'Error writing to file .arcflow.yml: {e}')

        # disable Archon integration if it was enabled for a single run
        if (self.include_digital_objects and 
                hasattr(self, 'use_archon') and self.use_archon == 2):
            try:
                with open(self.omeka_file_path, 'r') as file:
                    lines = file.readlines()
                with open(self.omeka_file_path, 'w') as file:
                    for line in lines:
                        if re.match(r'^\s*use_archon\s*:', line):
                            file.write('use_archon: 0\n')
                        else:
                            file.write(line)
                    self.log.info(f'Updated file .omeka.yml.')
            except Exception as e:
                self.log.error(f'Error writing to file .omeka.yml: {e}')


    def run(self):
        """
        Run the ArcFlow process.
        """
        self.log.info(f'ArcFlow process started (PID: {self.pid}).')
        self.update_repositories()
        self.update_eads()
        self.save_config_files()
        self.log.info(f'ArcFlow process completed (PID: {self.pid}). Elapsed time: {time.strftime("%H:%M:%S", time.gmtime(int(time.time()) - self.start_time))}.')


def main():
    parser = argparse.ArgumentParser(description='ArcFlow')
    parser.add_argument(
        '--arclight-dir',
        required=True,
        help='Path to ArcLight installation directory',)
    parser.add_argument(
        '--aspace-dir',
        required=True,
        help='Path to ArchivesSpace installation directory',)
    parser.add_argument(
        '--include-digital-objects',
        action='store_true',
        help='Include processing ArchivesSpace digital objects into Omeka items',)
    parser.add_argument(
        '--force-update',
        action='store_true',
        help='Force update of data',)
    parser.add_argument(
        '--solr-url',
        required=True,
        help='URL of the Solr core',)
    parser.add_argument(
        '--traject-extra-config',
        default='',
        help='Path to extra Traject configuration file',)
    parser.add_argument(
        '--dry-run-aspace',
        action='store_true',
        help='Run the process without making any changes or triggering any jobs in ArchivesSpace (for testing purposes)',)
    args = parser.parse_args()

    arcflow = ArcFlow(
        arclight_dir=args.arclight_dir,
        aspace_dir=args.aspace_dir,
        solr_url=args.solr_url,
        traject_extra_config=args.traject_extra_config,
        include_digital_objects=args.include_digital_objects,
        force_update=args.force_update,
        dry_run_aspace=args.dry_run_aspace)
    arcflow.run()


if __name__ == '__main__':
    main()