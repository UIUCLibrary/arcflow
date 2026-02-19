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
import sys
import glob
from xml.dom.pulldom import parse, START_ELEMENT
from xml.sax.saxutils import escape as xml_escape
from xml.etree import ElementTree as ET
from datetime import datetime, timezone
from asnake.client import ASnakeClient
from multiprocessing.pool import ThreadPool as Pool
from .utils.stage_classifications import extract_labels


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


    def __init__(self, arclight_dir, aspace_dir, solr_url, traject_extra_config='', force_update=False, agents_only=False, collections_only=False, arcuit_dir=None, skip_creator_indexing=False):
        self.solr_url = solr_url
        self.batch_size = 1000
        clean_extra_config = traject_extra_config.strip()
        self.traject_extra_config = clean_extra_config or None
        self.arclight_dir = arclight_dir
        self.aspace_jobs_dir = f'{aspace_dir}/data/shared/job_files'
        self.job_type = 'print_to_pdf_job'
        self.force_update = force_update
        self.agents_only = agents_only
        self.collections_only = collections_only
        self.arcuit_dir = arcuit_dir
        self.skip_creator_indexing = skip_creator_indexing
        self.log = logging.getLogger('arcflow')
        self.pid = os.getpid()
        self.pid_file_path = os.path.join(base_dir, 'arcflow.pid')
        self.arcflow_file_path = os.path.join(base_dir, '.arcflow.yml')
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
                self.last_updated = datetime.strptime(
                    config['last_updated'], '%Y-%m-%dT%H:%M:%S%z')
            except Exception as e:
                self.log.error(f'Error parsing last_updated date on file .arcflow.yml: {e}')
                exit(0)
        except FileNotFoundError:
            if not self.force_update:
                self.log.error('File .arcflow.yml not found. Create the file and try again or run with --force-update to recreate EADs from scratch.')
                exit(0)
            else:
                self.last_updated = datetime.fromtimestamp(0, timezone.utc)
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
                if (self.last_updated <= datetime.strptime(
                        repo['system_mtime'].replace('Z','+0000'),
                        '%Y-%m-%dT%H:%M:%S%z')
                        or self.last_updated <= datetime.strptime(
                        repo['user_mtime'].replace('Z','+0000'),
                        '%Y-%m-%dT%H:%M:%S%z')):
                    update_repos = True
                    break

        if update_repos:
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


    def task_resource(self, repo, resource_id, xml_dir, pdf_dir, indent_size=0):
        indent = ' ' * indent_size
        pdf_job = (None, None, None)
        resource = self.client.get(
            f'{repo["uri"]}/resources/{resource_id}',
            params={
                'resolve': ['classifications', 'classification_terms', 'linked_agents'],
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

            # add custom XML elements to EAD inside <archdesc level="collection">
            # (record group/subgroup labels and biographical/historical notes)
            if xml.content:
                xml_content = xml.content.decode('utf-8')
                insert_pos = xml_content.find('<archdesc level="collection">')
                
                if insert_pos != -1:
                    # Find the position after the closing </did> tag
                    did_end_pos = xml_content.find('</did>', insert_pos)
                    
                    if did_end_pos != -1:
                        # Move to after the </did> tag
                        did_end_pos += len('</did>')
                        extra_xml = ''
                        
                        # Add record group and subgroup labels
                        rg_label, sg_label = extract_labels(resource)[1:3]
                        if rg_label:
                            extra_xml += f'\n<recordgroup>{xml_escape(rg_label)}</recordgroup>'
                            if sg_label:
                                extra_xml += f'\n<subgroup>{xml_escape(sg_label)}</subgroup>'
                        
                        # Handle biographical/historical notes from creator agents
                        bioghist_content = self.get_creator_bioghist(resource, indent_size=indent_size)
                        if bioghist_content:
                            # Check if there's already a bioghist element in the EAD
                            # Search for existing bioghist after </did> but before </archdesc>
                            archdesc_end = xml_content.find('</archdesc>', did_end_pos)
                            search_section = xml_content[did_end_pos:archdesc_end] if archdesc_end != -1 else xml_content[did_end_pos:]
                            
                            # Look for closing </bioghist> tag
                            existing_bioghist_end = search_section.rfind('</bioghist>')
                            
                            if existing_bioghist_end != -1:
                                # Found existing bioghist - insert agent elements INSIDE it (before closing tag)
                                insert_pos = did_end_pos + existing_bioghist_end
                                xml_content = (xml_content[:insert_pos] + 
                                    f'\n{bioghist_content}\n' + 
                                    xml_content[insert_pos:])
                            else:
                                # No existing bioghist - wrap agent elements in parent container
                                wrapped_content = f'<bioghist>\n{bioghist_content}\n</bioghist>'
                                extra_xml += f'\n{wrapped_content}'
                        
                        if extra_xml:
                            xml_content = (xml_content[:did_end_pos] + 
                                extra_xml + 
                                xml_content[did_end_pos:])
                
                xml_content = xml_content.encode('utf-8')
            else:
                xml_content = xml.content

            # next level of indentation for nested operations
            indent_size += 2

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


    def task_repository(self, repo, xml_dir, modified_since, indent_size=0):
        indent = ' ' * indent_size
        resources = self.client.get(f'{repo["uri"]}/resources',
            params={
                'all_ids': True,
                'modified_since': modified_since,
            }
        ).json()
        repo_id = self.get_repo_id(repo)
        self.resources_counter[repo_id] = 0
        self.log.info(f'{indent}Found {len(resources)} resources in repository ID {repo_id}.')

        # return the repository and its resources for next async processing step
        return (repo, resources)


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

                # delete to avoid accumulation of jobs in ArchivesSpace
                response = self.client.delete(f'{repo_uri}/jobs/{job_id}')
                if response.status_code == 200:
                    job_dir = f'{self.aspace_jobs_dir}/{self.job_type}_{job_id}'
                    # delete physical job directory
                    try:
                        shutil.rmtree(job_dir)
                    except Exception as e:
                        self.log.error(f'{indent}Error deleting ArchivesSpace directory "{job_dir}": {e}')
                else:
                    self.log.error(f'{indent}Failed to delete ArchivesSpace {self.job_type}_{job_id}. Status code: {response.status_code}')

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
        xml_dir = f'{self.arclight_dir}/public/xml'
        pdf_dir = f'{self.arclight_dir}/public/pdf'

        modified_since = int(self.last_updated.timestamp())
        
        if self.force_update or modified_since <= 0:
            modified_since = 0
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

        # create directories if don't exist
        for dir_path in (xml_dir, pdf_dir):
            os.makedirs(dir_path, exist_ok=True)

        # process resources that have been modified in ArchivesSpace since last update
        self.log.info('Fetching resources from ArchivesSpace...')
        repos = self.client.get('repositories').json()

        indent_size = 2
        self.resources_counter = {}
        with Pool(processes=10) as pool:
            # Tasks for processing repositories
            results_1 = [pool.apply_async(
                self.task_repository, 
                args=(repo, xml_dir, modified_since, indent_size)) 
                for repo in repos]
            # Collect outputs from repository tasks
            outputs_1 = [r.get() for r in results_1]

            # Tasks for processing resources
            results_2 = [pool.apply_async(
                self.task_resource, 
                args=(repo, resource_id, xml_dir, pdf_dir, indent_size)) 
                for repo, resources in outputs_1 for resource_id in resources]
            # Collect outputs from resource tasks
            outputs_2 = [r.get() for r in results_2]

            # Create batches for indexing pending resources
            batches = []
            for repo, resources in self.resources_counter.items():
                num_batches = math.ceil(resources/self.batch_size)
                for batch_num in range(1, num_batches + 1):
                    batches.append((repo, batch_num))

            # Tasks for indexing pending resources
            results_3 = [pool.apply_async(
                self.index_collections,
                args=(repo_id, f'{xml_dir}/{repo_id}_*_batch_{batch_num}.xml', indent_size))
                for repo_id, batch_num in batches]

            # Wait for indexing tasks to complete
            for r in results_3:
                r.get()

            # Remove pending symlinks after indexing
            for repo_id, batch_num in batches:
                xml_file_pattern = f'{xml_dir}/{repo_id}_*_batch_{batch_num}.xml'
                xml_files = glob.glob(xml_file_pattern)
                
                for xml_file_path in xml_files:
                    try:
                        os.remove(xml_file_path)
                        self.log.info(f'{" " * indent_size}Removed pending symlink {xml_file_path}')
                    except FileNotFoundError:
                        self.log.warning(f'{" " * indent_size}File not found: {xml_file_path}')
                    except Exception as e:
                        self.log.error(f'{" " * indent_size}Error removing pending symlink {xml_file_path}: {e}')

            # Tasks for processing PDFs
            results_4 = [pool.apply_async(
                self.task_pdf,
                args=(repo_uri, job_id, ead_id, pdf_dir, indent_size))
                for repo_uri, job_id, ead_id in outputs_2 if job_id is not None]

            # Wait for PDF tasks to complete
            for r in results_4:
                r.get()

        # processing deleted resources is not needed when 
        # force-update is set or modified_since is set to 0
        if self.force_update or modified_since <= 0:
            self.log.info('Skipping deleted resources processing.')
            return

        # process resources that have been deleted since last update in ArchivesSpace
        pattern = r'^/repositories/(?P<repo_id>\d+)/resources/(?P<resource_id>\d+)$'
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
                    resource_id = match.group('resource_id')
                    self.log.info(f'{" " * indent_size}Processing deleted resource ID {resource_id}...')

                    symlink_path = f'{xml_dir}/{resource_id}.xml'
                    ead_id = self.get_ead_from_symlink(symlink_path)
                    if ead_id:
                        self.delete_ead(
                            resource_id, 
                            ead_id.replace('.', '-'),  # dashes in Solr
                            f'{xml_dir}/{ead_id}.xml', # dots in filenames
                            f'{pdf_dir}/{ead_id}.pdf', 
                            indent=4)
                    else:
                        self.log.error(f'{" " * (indent_size+2)}Symlink {symlink_path} not found. Unable to delete the associated EAD from Arclight Solr.')

            if deleted_records['last_page'] == page:
                break
            page += 1


    def index_collections(self, repo_id, xml_file_path, indent_size=0):
        """Index collection XML files to Solr using traject."""
        indent = ' ' * indent_size
        self.log.info(f'{indent}Indexing pending resources in repository ID {repo_id} to ArcLight Solr...')
        try:
            # Get arclight traject config path
            result_show = subprocess.run(
                ['bundle', 'show', 'arclight'],
                capture_output=True,
                text=True,
                cwd=self.arclight_dir
            )
            arclight_path = result_show.stdout.strip() if result_show.returncode == 0 else ''
            
            if not arclight_path:
                self.log.error(f'{indent}Could not find arclight gem path')
                return
            
            traject_config = f'{arclight_path}/lib/arclight/traject/ead2_config.rb'
            
            cmd = [
                'bundle', 'exec', 'traject',
                '-u', self.solr_url,
                '-s', 'processing_thread_pool=8',
                '-s', 'solr_writer.thread_pool=8',
                '-s', f'solr_writer.batch_size={self.batch_size}',
                '-s', 'solr_writer.commit_on_close=true',
                '-i', 'xml',
                '-c', traject_config
            ]
            
            if self.traject_extra_config:
                if isinstance(self.traject_extra_config, (list, tuple)):
                    cmd.extend(self.traject_extra_config)
                else:
                    # Treat a string extra config as a path and pass it with -c
                    cmd.extend(['-c', self.traject_extra_config])
            
            # Expand wildcards with glob
            xml_files = glob.glob(xml_file_path)
            
            if not xml_files:
                self.log.warning(f'{indent}No files found matching pattern: {xml_file_path}')
                return
            
            # Add all matching files to the command
            cmd.extend(xml_files)
            
            env = os.environ.copy()
            env['REPOSITORY_ID'] = str(repo_id)
            
            result = subprocess.run(
                cmd,
                cwd=self.arclight_dir,
                env=env,
                stderr=subprocess.PIPE,
            )

            if result.stderr:
                self.log.error(f'{indent}{result.stderr.decode("utf-8")}')
            if result.returncode != 0:
                self.log.error(f'{indent}Failed to index pending resources in repository ID {repo_id} to ArcLight Solr. Return code: {result.returncode}')
            else:
                self.log.info(f'{indent}Finished indexing pending resources in repository ID {repo_id} to ArcLight Solr.')
        except subprocess.CalledProcessError as e:
            self.log.error(f'{indent}Error indexing pending resources in repository ID {repo_id} to ArcLight Solr: {e}')


    def get_creator_bioghist(self, resource, indent_size=0):
        """
        Get biographical/historical notes from creator agents linked to the resource.
        Returns nested bioghist elements for each creator, or None if no creator agents have notes.
        Each bioghist element includes the creator name in a head element and an id attribute.
        """
        indent = ' ' * indent_size
        bioghist_elements = []
        
        if 'linked_agents' not in resource:
            return None
        
        # Process linked_agents in order to maintain consistency with origination order
        for linked_agent in resource['linked_agents']:
            # Only process agents with 'creator' role
            if linked_agent.get('role') == 'creator':
                agent_ref = linked_agent.get('ref')
                if agent_ref:
                    try:
                        agent = self.client.get(agent_ref).json()
                        
                        # Get agent name for head element
                        agent_name = agent.get('title') or agent.get('display_name', {}).get('sort_name', 'Unknown')
                        
                        # Check for notes in the agent record
                        if 'notes' in agent:
                            for note in agent['notes']:
                                # Look for biographical/historical notes
                                if note.get('jsonmodel_type') == 'note_bioghist':
                                    # Get persistent_id for the id attribute
                                    persistent_id = note.get('persistent_id', '')
                                    if not persistent_id:
                                        self.log.error(f'{indent}**ASSUMPTION VIOLATION**: Expected persistent_id in note_bioghist for agent {agent_ref}')
                                        # Skip creating id attribute if persistent_id is missing
                                        persistent_id = None
                                    
                                    # Extract note content from subnotes
                                    paragraphs = []
                                    if 'subnotes' in note:
                                        for subnote in note['subnotes']:
                                            if 'content' in subnote:
                                                # Split content on single newlines to create paragraphs
                                                content = subnote['content']
                                                # Handle content as either string or list with explicit type checking
                                                if isinstance(content, str):
                                                    # Split on newline and filter out empty strings
                                                    lines = [line.strip() for line in content.split('\n') if line.strip()]
                                                elif isinstance(content, list):
                                                    # Content is already a list - use as is
                                                    lines = [str(item).strip() for item in content if str(item).strip()]
                                                else:
                                                    # Log unexpected content type prominently
                                                    self.log.error(f'{indent}**ASSUMPTION VIOLATION**: Expected string or list for subnote content in agent {agent_ref}, got {type(content).__name__}')
                                                    continue
                                                # Wrap each line in <p> tags
                                                for line in lines:
                                                    paragraphs.append(f'<p>{line}</p>')
                                    
                                    # Create nested bioghist element if we have paragraphs
                                    if paragraphs:
                                        paragraphs_xml = '\n'.join(paragraphs)
                                        heading = f'Historical Note from {xml_escape(agent_name)} Creator Record'
                                        # Only include id attribute if persistent_id is available
                                        if persistent_id:
                                            bioghist_el = f'<bioghist id="aspace_{persistent_id}"><head>{heading}</head>\n{paragraphs_xml}\n</bioghist>'
                                        else:
                                            bioghist_el = f'<bioghist><head>{heading}</head>\n{paragraphs_xml}\n</bioghist>'
                                        bioghist_elements.append(bioghist_el)
                    except Exception as e:
                        self.log.error(f'{indent}Error fetching biographical information for agent {agent_ref}: {e}')
        
        if bioghist_elements:
            # Return the agent bioghist elements (unwrapped)
            # The caller will decide whether to wrap them based on whether
            # an existing bioghist element exists
            return '\n'.join(bioghist_elements)
        return None


    def is_target_agent(self, agent):
        """
        Determine if agent is a target creator of archival materials.
        
        Excludes:
        - System users (is_user field present)
        - System-generated agents (system_generated = true)
        - Repository agents (is_repo_agent field present)
        - Donor-only agents (only has 'donor' role, no creator role)
        
        Note: Software agents are excluded by not querying /agents/software endpoint.
        
        Args:
            agent: Agent record from ArchivesSpace API
            
        Returns:
            bool: True if agent should be indexed, False to exclude
        """
        # TIER 1: Exclude system users (PRIMARY FILTER)
        if agent.get('is_user'):
            return False
        
        # TIER 2: Exclude system-generated agents
        if agent.get('system_generated'):
            return False
        
        # TIER 3: Exclude repository agents (corporate entities only)
        if agent.get('is_repo_agent'):
            return False
        
        # TIER 4: Role-based filtering
        roles = agent.get('linked_agent_roles', [])
        
        # Include if explicitly marked as creator
        if 'creator' in roles:
            return True
        
        # Exclude if ONLY marked as donor
        if roles == ['donor']:
            return False
        
        # TIER 5: Default - include if linked to published records
        # (covers cases where roles aren't populated yet)
        return agent.get('is_linked_to_published_record', False)

    def get_all_agents(self, agent_types=None, modified_since=0, indent_size=0):
        """
        Fetch target agents from ArchivesSpace and filter to creators only.
        Excludes system users, donors, and other non-creator agents.
        
        Args:
            agent_types: List of agent types to fetch. Default: ['corporate_entities', 'people', 'families']
            modified_since: Unix timestamp to filter agents modified since this time (if API supports it)
            indent_size: Indentation size for logging
            
        Returns:
            list: List of filtered agent URIs (e.g., '/agents/corporate_entities/123')
        """
        if agent_types is None:
            agent_types = ['corporate_entities', 'people', 'families']
        
        indent = ' ' * indent_size
        target_agents = []
        stats = {
            'total': 0,
            'excluded_user': 0,
            'excluded_system_generated': 0,
            'excluded_repo_agent': 0,
            'excluded_donor_only': 0,
            'excluded_no_links': 0,
            'included': 0
        }
        
        self.log.info(f'{indent}Fetching agents from ArchivesSpace and applying filters...')
        
        for agent_type in agent_types:
            try:
                # Try with modified_since parameter first
                params = {'all_ids': True}
                if modified_since > 0:
                    params['modified_since'] = modified_since
                
                response = self.client.get(f'/agents/{agent_type}', params=params)
                agent_ids = response.json()
                
                self.log.info(f'{indent}Found {len(agent_ids)} {agent_type} agents, filtering...')
                
                # Fetch and filter each agent
                for agent_id in agent_ids:
                    stats['total'] += 1
                    agent_uri = f'/agents/{agent_type}/{agent_id}'
                    
                    try:
                        # Fetch full agent record to access filtering fields
                        agent_response = self.client.get(agent_uri)
                        agent = agent_response.json()
                        
                        # Apply filtering logic
                        if agent.get('is_user'):
                            stats['excluded_user'] += 1
                            continue
                        
                        if agent.get('system_generated'):
                            stats['excluded_system_generated'] += 1
                            continue
                        
                        if agent.get('is_repo_agent'):
                            stats['excluded_repo_agent'] += 1
                            continue
                        
                        roles = agent.get('linked_agent_roles', [])
                        
                        # Include creators
                        if 'creator' in roles:
                            stats['included'] += 1
                            target_agents.append(agent_uri)
                            continue
                        
                        # Exclude donor-only agents
                        if roles == ['donor']:
                            stats['excluded_donor_only'] += 1
                            continue
                        
                        # Default: include if linked to published records
                        if agent.get('is_linked_to_published_record', False):
                            stats['included'] += 1
                            target_agents.append(agent_uri)
                        else:
                            stats['excluded_no_links'] += 1
                            
                    except Exception as e:
                        self.log.warning(f'{indent}Error fetching agent {agent_uri}: {e}')
                        # On error, include the agent (fail-open)
                        target_agents.append(agent_uri)
                    
            except Exception as e:
                self.log.error(f'{indent}Error fetching {agent_type} agents: {e}')
                # If modified_since fails, try without it
                if modified_since > 0:
                    self.log.warning(f'{indent}Retrying {agent_type} without modified_since filter...')
                    try:
                        response = self.client.get(f'/agents/{agent_type}', params={'all_ids': True})
                        agent_ids = response.json()
                        self.log.info(f'{indent}Found {len(agent_ids)} {agent_type} agents (no date filter)')
                        
                        # Re-process with filtering
                        for agent_id in agent_ids:
                            stats['total'] += 1
                            agent_uri = f'/agents/{agent_type}/{agent_id}'
                            
                            try:
                                agent_response = self.client.get(agent_uri)
                                agent = agent_response.json()
                                
                                if self.is_target_agent(agent):
                                    stats['included'] += 1
                                    target_agents.append(agent_uri)
                                    
                            except Exception as e:
                                self.log.warning(f'{indent}Error fetching agent {agent_uri}: {e}')
                                target_agents.append(agent_uri)
                                
                    except Exception as e2:
                        self.log.error(f'{indent}Failed to fetch {agent_type} agents: {e2}')
        
        # Log filtering statistics
        self.log.info(f'{indent}Agent filtering complete:')
        self.log.info(f'{indent}  Total agents processed: {stats["total"]}')
        self.log.info(f'{indent}  Included (target creators): {stats["included"]}')
        self.log.info(f'{indent}  Excluded (system users): {stats["excluded_user"]}')
        self.log.info(f'{indent}  Excluded (system-generated): {stats["excluded_system_generated"]}')
        self.log.info(f'{indent}  Excluded (repository agents): {stats["excluded_repo_agent"]}')
        self.log.info(f'{indent}  Excluded (donor-only): {stats["excluded_donor_only"]}')
        self.log.info(f'{indent}  Excluded (no published links): {stats["excluded_no_links"]}')
        
        return target_agents


    def task_agent(self, agent_uri, agents_dir, repo_id=1, indent_size=0):
        """
        Process a single agent and generate a creator document in EAC-CPF XML format.
        Retrieves EAC-CPF directly from ArchivesSpace archival_contexts endpoint.
        
        Args:
            agent_uri: Agent URI from ArchivesSpace (e.g., '/agents/corporate_entities/123')
            agents_dir: Directory to save agent XML files
            repo_id: Repository ID to use for archival_contexts endpoint (default: 1)
            indent_size: Indentation size for logging
            
        Returns:
            str: Creator document ID if successful, None otherwise
        """
        indent = ' ' * indent_size
        
        try:
            # Parse agent URI to extract type and ID
            # URI format: /agents/{agent_type}/{id}
            parts = agent_uri.strip('/').split('/')
            if len(parts) != 3 or parts[0] != 'agents':
                self.log.error(f'{indent}Invalid agent URI format: {agent_uri}')
                return None
            
            agent_type = parts[1]  # e.g., 'corporate_entities', 'people', 'families'
            agent_id = parts[2]
            
            # Construct EAC-CPF endpoint
            # Format: /repositories/{repo_id}/archival_contexts/{agent_type}/{id}.xml
            eac_cpf_endpoint = f'/repositories/{repo_id}/archival_contexts/{agent_type}/{agent_id}.xml'
            
            self.log.debug(f'{indent}Fetching EAC-CPF from: {eac_cpf_endpoint}')
            
            # Fetch EAC-CPF XML
            response = self.client.get(eac_cpf_endpoint)
            
            if response.status_code != 200:
                self.log.error(f'{indent}Failed to fetch EAC-CPF for {agent_uri}: HTTP {response.status_code}')
                return None
            
            eac_cpf_xml = response.text
            
            # Parse the EAC-CPF XML to validate and inspect its structure
            try:
                root = ET.fromstring(eac_cpf_xml)
                self.log.debug(f'{indent}Parsed EAC-CPF XML root element: {root.tag}')
            except ET.ParseError as e:
                self.log.error(f'{indent}Failed to parse EAC-CPF XML for {agent_uri}: {e}')
                return None
            
            # Generate creator ID
            creator_id = f'creator_{agent_type}_{agent_id}'
            
            # Save EAC-CPF XML to file
            filename = f'{agents_dir}/{creator_id}.xml'
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(eac_cpf_xml)
            
            self.log.info(f'{indent}Created creator document: {creator_id}')
            return creator_id
            
        except Exception as e:
            self.log.error(f'{indent}Error processing agent {agent_uri}: {e}')
            import traceback
            self.log.error(f'{indent}{traceback.format_exc()}')
            return None

    def process_creators(self):
        """
        Process creator agents and generate standalone creator documents.

        Returns:
            list: List of created creator document IDs
        """

        xml_dir = f'{self.arclight_dir}/public/xml'
        agents_dir = f'{xml_dir}/agents'
        modified_since = int(self.last_updated.timestamp())
        indent_size = 0
        indent = ' ' * indent_size

        self.log.info(f'{indent}Processing creator agents...')

        # Create agents directory if it doesn't exist
        os.makedirs(agents_dir, exist_ok=True)

        # Get agents to process
        agents = self.get_all_agents(modified_since=modified_since, indent_size=indent_size)

        # Process agents in parallel
        with Pool(processes=10) as pool:
            results_agents = [pool.apply_async(
                self.task_agent,
                args=(agent_uri_item, agents_dir, 1, indent_size))  # Use repo_id=1
                for agent_uri_item in agents]

            creator_ids = [r.get() for r in results_agents]
            creator_ids = [cid for cid in creator_ids if cid is not None]

        self.log.info(f'{indent}Created {len(creator_ids)} creator documents.')

        # NOTE: Collection links are NOT added to creator XML files.
        # Instead, linking is handled via Solr using the persistent_id field:
        # - Creator bioghist has persistent_id as the 'id' attribute
        # - Collection EADs reference creators via bioghist with persistent_id
        # - Solr indexes both, allowing queries to link them
        # This avoids the expensive operation of scanning all resources to build a linkage map.

        # Index creators to Solr (if not skipped)
        if not self.skip_creator_indexing and creator_ids:
            self.log.info(f'{indent}Indexing {len(creator_ids)} creator records to Solr...')
            traject_config = self.find_traject_config()
            if traject_config:
                self.log.info(f'{indent}Using traject config: {traject_config}')
                indexed = self.index_creators(agents_dir, creator_ids)
                self.log.info(f'{indent}Creator indexing complete: {indexed}/{len(creator_ids)} indexed')
            else:
                self.log.warning(f'{indent}Skipping creator indexing (traject config not found)')
                self.log.info(f'{indent}To index manually:')
                self.log.info(f'{indent}  cd {self.arclight_dir}')
                self.log.info(f'{indent}  bundle exec traject -u {self.solr_url} -i xml \\')
                self.log.info(f'{indent}    -c /path/to/arcuit-gem/traject_config_eac_cpf.rb \\')
                self.log.info(f'{indent}    {agents_dir}/*.xml')
        elif self.skip_creator_indexing:
            self.log.info(f'{indent}Skipping creator indexing (--skip-creator-indexing flag set)')

        return creator_ids


    def find_traject_config(self):
        """
        Find the traject config for creator indexing.
        
        Search order (follows collection records pattern):
        1. arcuit_dir if provided (most up-to-date user control)
        2. arcuit gem via bundle show (for backward compatibility)
        3. example_traject_config_eac_cpf.rb in arcflow (fallback when used as module without arcuit)
        
        Returns:
            str: Path to traject config, or None if not found
        """
        self.log.info('Searching for traject_config_eac_cpf.rb...')
        searched_paths = []
        
        # Try 1: arcuit_dir if provided (highest priority - user's explicit choice)
        if self.arcuit_dir:
            self.log.debug(f'  Checking arcuit_dir parameter: {self.arcuit_dir}')
            candidate_paths = [
                os.path.join(self.arcuit_dir, 'traject_config_eac_cpf.rb'),
                os.path.join(self.arcuit_dir, 'lib', 'arcuit', 'traject', 'traject_config_eac_cpf.rb'),
            ]
            searched_paths.extend(candidate_paths)
            for traject_config in candidate_paths:
                if os.path.exists(traject_config):
                    self.log.info(f'✓ Using traject config from arcuit_dir: {traject_config}')
                    return traject_config
            self.log.debug('  traject_config_eac_cpf.rb not found in arcuit_dir')
        
        # Try 2: bundle show arcuit (for backward compatibility when arcuit_dir not provided)
        try:
            result = subprocess.run(
                ['bundle', 'show', 'arcuit'],
                cwd=self.arclight_dir,
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                arcuit_path = result.stdout.strip()
                self.log.debug(f'  Found arcuit gem at: {arcuit_path}')
                candidate_paths = [
                    os.path.join(arcuit_path, 'traject_config_eac_cpf.rb'),
                    os.path.join(arcuit_path, 'lib', 'arcuit', 'traject', 'traject_config_eac_cpf.rb'),
                ]
                searched_paths.extend(candidate_paths)
                for traject_config in candidate_paths:
                    if os.path.exists(traject_config):
                        self.log.info(f'✓ Using traject config from arcuit gem: {traject_config}')
                        return traject_config
                self.log.debug(
                    '  traject_config_eac_cpf.rb not found in arcuit gem '
                    '(checked root and lib/arcuit/traject/ subdirectory)'
                )
            else:
                self.log.debug('  arcuit gem not found via bundle show')
        except Exception as e:
            self.log.debug(f'  Error checking for arcuit gem: {e}')
        
        # Try 3: example file in arcflow package (fallback for module usage without arcuit)
        # We know exactly where this file is located - at the repo root
        arcflow_package_dir = os.path.dirname(os.path.abspath(__file__))
        arcflow_repo_root = os.path.dirname(arcflow_package_dir)
        traject_config = os.path.join(arcflow_repo_root, 'example_traject_config_eac_cpf.rb')
        searched_paths.append(traject_config)
        
        if os.path.exists(traject_config):
            self.log.info(f'✓ Using example traject config from arcflow: {traject_config}')
            self.log.info(
                '  Note: Using example config. For production, copy this file to your '
                'arcuit gem or specify location with --arcuit-dir.'
            )
            return traject_config
        
        # No config found anywhere - show all paths searched
        self.log.error('✗ Could not find traject_config_eac_cpf.rb in any of these locations:')
        for i, path in enumerate(searched_paths, 1):
            self.log.error(f'  {i}. {path}')
        self.log.error('')
        self.log.error('  Add traject_config_eac_cpf.rb to your arcuit gem or specify with --arcuit-dir.')
        return None


    def index_creators(self, agents_dir, creator_ids, batch_size=100):
        """
        Index creator XML files to Solr using traject.
        
        Args:
            agents_dir: Directory containing creator XML files
            creator_ids: List of creator IDs to index
            batch_size: Number of files to index per traject call (default: 100)
        
        Returns:
            int: Number of successfully indexed creators
        """
        traject_config = self.find_traject_config()
        if not traject_config:
            return 0
        
        indexed_count = 0
        failed_count = 0
        
        # Process in batches to avoid command line length limits
        total_batches = math.ceil(len(creator_ids) / batch_size)
        for i in range(0, len(creator_ids), batch_size):
            batch = creator_ids[i:i+batch_size]
            batch_num = (i // batch_size) + 1
            
            # Build list of XML files for this batch
            xml_files = [f'{agents_dir}/{cid}.xml' for cid in batch]
            
            # Filter to only existing files
            existing_files = [f for f in xml_files if os.path.exists(f)]
            
            if not existing_files:
                self.log.warning(f'  Batch {batch_num}/{total_batches}: No files found, skipping')
                continue
            
            try:
                cmd = [
                    'bundle', 'exec', 'traject',
                    '-u', self.solr_url,
                    '-i', 'xml',
                    '-c', traject_config
                ] + existing_files
                
                self.log.info(f'  Indexing batch {batch_num}/{total_batches}: {len(existing_files)} files')
                
                result = subprocess.run(
                    cmd,
                    cwd=self.arclight_dir,
                    stderr=subprocess.PIPE,
                    timeout=300  # 5 minute timeout per batch
                )
                
                if result.returncode == 0:
                    indexed_count += len(existing_files)
                    self.log.info(f'  Successfully indexed {len(existing_files)} creators')
                else:
                    failed_count += len(existing_files)
                    self.log.error(f'  Traject failed with exit code {result.returncode}')
                    if result.stderr:
                        self.log.error(f'  STDERR: {result.stderr.decode("utf-8")}')
                    
            except subprocess.TimeoutExpired:
                self.log.error(f'  Traject timed out for batch {batch_num}/{total_batches}')
                failed_count += len(existing_files)
            except Exception as e:
                self.log.error(f'  Error indexing batch {batch_num}/{total_batches}: {e}')
                failed_count += len(existing_files)

        if failed_count > 0:
            self.log.warning(f'Creator indexing completed with errors: {indexed_count} succeeded, {failed_count} failed')
        
        return indexed_count


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


    def save_config_file(self):
        """
        Save the last updated timestamp to the .arcflow.yml file.
        """
        try:
            with open(self.arcflow_file_path, 'w') as file:
                yaml.dump({
                    'last_updated': datetime.fromtimestamp(self.start_time, timezone.utc).strftime('%Y-%m-%dT%H:%M:%S%z')
                }, file)
                self.log.info(f'Saved file .arcflow.yml.')
        except Exception as e:
            self.log.error(f'Error writing to file .arcflow.yml: {e}')


    def run(self):
        """
        Run the ArcFlow process.
        """
        self.log.info(f'ArcFlow process started (PID: {self.pid}).')
        
        # Update repositories (unless agents-only mode)
        if not self.agents_only:
            self.update_repositories()
        
        # Update collections/EADs (unless agents-only mode)
        if not self.agents_only:
            self.update_eads()
        
        # Update creator records (unless collections-only mode)
        if not self.collections_only:
            self.process_creators()
        
        self.save_config_file()
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
        '--agents-only',
        action='store_true',
        help='Process only agent records, skip collections (for testing)',)
    parser.add_argument(
        '--collections-only',
        action='store_true',
        help='Process only repositories and collections, skip creator processing',)
    parser.add_argument(
        '--arcuit-dir',
        default=None,
        help='Path to arcuit repository (for traject config). If not provided, will try bundle show arcuit.',)
    parser.add_argument(
        '--skip-creator-indexing',
        action='store_true',
        help='Generate creator XML files but skip Solr indexing (for testing)',)
    args = parser.parse_args()
    
    # Validate mutually exclusive flags
    if args.agents_only and args.collections_only:
        parser.error('Cannot use both --agents-only and --collections-only')

    arcflow = ArcFlow(
        arclight_dir=args.arclight_dir,
        aspace_dir=args.aspace_dir,
        solr_url=args.solr_url,
        traject_extra_config=args.traject_extra_config,
        force_update=args.force_update,
        agents_only=args.agents_only,
        collections_only=args.collections_only,
        arcuit_dir=args.arcuit_dir,
        skip_creator_indexing=args.skip_creator_indexing)
    arcflow.run()


if __name__ == '__main__':
    main()