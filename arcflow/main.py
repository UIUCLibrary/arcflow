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
from xml.dom.pulldom import parse, START_ELEMENT
from datetime import datetime, timezone
from asnake.client import ASnakeClient
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


    def __init__(self, arclight_dir, aspace_dir, solr_url, traject_extra_config='', force_update=False):
        self.solr_url = solr_url
        self.traject_extra_config = f'-c {traject_extra_config}' if traject_extra_config.strip() else ''
        self.arclight_dir = arclight_dir
        self.aspace_jobs_dir = f'{aspace_dir}/data/shared/job_files'
        self.job_type = 'print_to_pdf_job'

        self.force_update = force_update

        self.log = logging.getLogger('arcflow')
        self.pid = os.getpid()
        self.pid_file_path = os.path.join(base_dir, 'arcflow.pid')
        if self.is_running():
            self.log.info(f'ArcFlow process previously started still running. Exiting (PID: {self.pid}).')
            exit(0)
        else:
            self.create_pid_file()

        self.start_time = int(time.time())
        try:
            with open('.arcflow.yml', 'r') as file:
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
            with open('.archivessnake.yml', 'r') as file:
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
                xml_content = xml.content.decode('utf-8')
                insert_pos = xml_content.find('<archdesc level="collection">')
                
                if insert_pos != -1:
                    # Find the position after the closing </did> tag
                    insert_pos = xml_content.find('</did>', insert_pos)
                    
                    if insert_pos != -1:
                        # Move to after the </did> tag
                        insert_pos += len('</did>')
                        extra_xml = ''
                        
                        # Add record group and subgroup labels
                        rg_label, sg_label = extract_labels(resource)[1:3]
                        if rg_label:
                            extra_xml += f'<recordgroup>{rg_label}</recordgroup>'
                            if sg_label:
                                extra_xml += f'<subgroup>{sg_label}</subgroup>'
                        
                        if extra_xml:
                            xml_content = (xml_content[:insert_pos] + 
                                extra_xml + 
                                xml_content[insert_pos:])
                
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
            # files pending to index are named repoID_resourceID_pending.xml 
            self.create_symlink(
                os.path.basename(xml_file_path),
                f'{os.path.dirname(xml_file_path)}/{self.get_repo_id(repo)}_{resource_id}_pending.xml',
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
        num_resources = len(resources)
        self.log.info(f'{indent}Found {len(resources)} resources in repository ID {self.get_repo_id(repo)}.')

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

            # Tasks for indexing pending resources
            results_3 = [pool.apply_async(
                self.index,
                args=(self.get_repo_id(repo), f'{xml_dir}/{self.get_repo_id(repo)}_*_pending.xml', indent_size))
                for repo in repos]

            # Tasks for processing PDFs
            results_4 = [pool.apply_async(
                self.task_pdf,
                args=(repo_uri, job_id, ead_id, pdf_dir, indent_size))
                for repo_uri, job_id, ead_id in outputs_2 if job_id is not None]

            # Wait for indexing tasks to complete
            for r in results_3:
                r.get()
            
            # Remove pending symlinks after indexing
            for repo in repos:
                repo_id = self.get_repo_id(repo)
                xml_file_path = f'{xml_dir}/{repo_id}_*_pending.xml'
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


    def index(self, repo_id, xml_file_path, indent_size=0):
        indent = ' ' * indent_size
        self.log.info(f'{indent}Indexing pending resources in repository ID {repo_id} to ArcLight Solr...')
        try:
            result = subprocess.run(
                f'REPOSITORY_ID={repo_id} bundle exec traject -u {self.solr_url} -s processing_thread_pool=8 -s solr_writer.thread_pool=8 -s solr_writer.batch_size=1000 -s solr_writer.commit_on_close=true -i xml -c $(bundle show arclight)/lib/arclight/traject/ead2_config.rb {self.traject_extra_config} {xml_file_path}',
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


    def save_config_file(self):
        """
        Save the last updated timestamp to the .arcflow.yml file.
        """
        try:
            with open('.arcflow.yml', 'w') as file:
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
        self.update_repositories()
        self.update_eads()
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
    args = parser.parse_args()

    arcflow = ArcFlow(
        arclight_dir=args.arclight_dir,
        aspace_dir=args.aspace_dir,
        solr_url=args.solr_url,
        traject_extra_config=args.traject_extra_config,
        force_update=args.force_update)
    arcflow.run()


if __name__ == '__main__':
    main()