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

base_dir = os.path.abspath((__file__) + "/../../")
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname).1s - %(asctime)s - %(message)s',
    datefmt='%Y-%m-%dT%H:%M:%S%z',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(os.path.join(base_dir, 'arcflow.log')),
    ]
)

class ArcFlow:
    """
    ArcFlow is a class that represents a flow of data from ArchivesSpace 
    to ArcLight.
    """

    def __init__(self, arclight_dir, solr_url, force_update=False):
        self.solr_url = solr_url
        self.arclight_dir = arclight_dir
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
        try:
            with open('.archivessnake.yml', 'r') as file:
                config = yaml.safe_load(file)
        except FileNotFoundError:
            self.log.error('File .archivessnake.yml not found. Create the file.')
            exit(0)

        self.client = ASnakeClient(
            username=config['username'],
            password=config['password'],
            baseurl=config['baseurl'],
        )
        self.client.authorize()

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
                        repo['slug']: {
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

    def update_eads(self):
        """
        Update EADs in ArcLight with the latest data from resources in 
        ArchivesSpace.
        """
        eads_dir = f'{self.arclight_dir}/public/eads'

        modified_since = int(self.last_updated.timestamp())
        if self.force_update or modified_since <= 0:
            modified_since = 0
            # delete all EAD files and EADs in ArcLight Solr
            try:
                response = requests.post(
                    f'{self.solr_url}/update?commit=true',
                    json={'delete': {'query': '*:*'}},
                )
                if response.status_code == 200:
                    self.log.info('Deleted all EADs from ArcLight Solr.')
                    # delete ead directory after suscessful deletion from solr
                    try:
                        shutil.rmtree(eads_dir)
                        self.log.info(f'Deleted EADs directory {eads_dir}.')
                    except Exception as e:
                        self.log.error(f'Error deleting EADs directory "{eads_dir}": {e}')
                else:
                    self.log.error(f'Failed to delete all EADs from Arclight Solr. Status code: {response.status_code}')
            except requests.exceptions.RequestException as e:
                self.log.error(f'Error deleting all EADs from ArcLight Solr: {e}')

        # process resources that have been modified in ArchivesSpace since last update
        self.log.info('Fetching resources from ArchivesSpace...')
        repos = self.client.get('repositories').json()
        for repo in repos:
            eads_repo_dir = f'{eads_dir}/{repo["slug"]}'
            #create folder if doesn't exist
            if not os.path.exists(eads_repo_dir):
                os.makedirs(eads_repo_dir)

            resources = self.client.get(f'{repo["uri"]}/resources',
                params={
                    'all_ids': True,
                    'modified_since': modified_since,
                }
            ).json()
            for resource_id in resources:
                resource = self.client.get(
                    f'{repo["uri"]}/resources/{resource_id}').json()
                ead_file_path = f'{eads_repo_dir}/{resource_id}.xml'
                ead_id = resource['ead_id'].replace('.', '-')
                self.log.info(f'  Processing resource with ID {resource_id} ("{ead_id}")...')

                # TODO: make sure the EAD ID wasn't updated, otherwise
                # we need to delete the previous EAD in ArcLight Solr
                # so it doesn't become orphaned

                if resource['publish'] and not resource['suppressed']:
                    ead = self.client.get(
                        f'{repo["uri"]}/resource_descriptions/{resource_id}.xml',
                        params={
                            'include_unpublished': 'false',
                            'include_daos': 'true',
                            'include_uris': 'true',
                            'numbered_cs': 'true',
                            'ead3': 'false',
                        })

                    self.save_ead(
                        ead_file_path,
                        ead_id,
                        ead.content,
                        repo['slug'],
                        indent=4)
                else:
                    self.delete_ead(ead_file_path, ead_id, indent=4)

        # processing deleted resources is not be needed when 
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
                    repo_id = match.group('repo_id')
                    self.log.info(f'  Processing deleted resource with ID {resource_id}...')
                    repo = self.client.get(
                        f'/repositories/{repo_id}'
                    ).json()
                    ead_file_path = f'{eads_dir}/{repo["slug"]}/{resource_id}.xml'

                    ead_id = self.get_ead_id_from_file(ead_file_path)

                    if ead_id is None:
                        self.log.error(f'    File {ead_file_path} was not found or does not contain an "eadid" tag. Unable to delete the associated EAD from Arclight Solr.')
                    else:
                        self.delete_ead(ead_file_path, ead_id, indent=4)

            if deleted_records['last_page'] == page:
                break
            page += 1

    def get_ead_id_from_file(self, ead_file_path):
        """
        Get the EAD ID from the EAD file.
        """
        ead_id = None
        # parse the EAD file to get the ead_id
        if os.path.isfile(ead_file_path):
            ead = parse(ead_file_path)
            for event, node in ead:
                if event == START_ELEMENT and node.tagName == 'eadid':
                    ead.expandNode(node)
                    ead_id = node.firstChild.nodeValue
                    break

        return ead_id

    def save_ead(self, ead_file_path, ead_id, ead_content, repo_id, indent=0):
        indent = ' ' * indent
        #save ead to file
        try:
            with open(ead_file_path, 'wb') as file:
                file.write(ead_content)
                self.log.info(f'{indent}Saved file {ead_file_path}.')
                # add to solr after successful save
                try:
                    result = subprocess.run(
                        f'FILE={ead_file_path} SOLR_URL={self.solr_url} REPOSITORY_ID={repo_id} bundle exec rails arclight:index',
                        shell=True,
                        cwd=self.arclight_dir,
                        capture_output=True,)
                    if result.returncode == 0:
                        self.log.info(f'{indent}Updated EAD "{ead_id}" in ArcLight Solr.')
                    else:
                        self.log.error(f'{indent}Failed to update EAD "{ead_id}" in ArcLight Solr. Return code: {result.returncode}')
                        self.log.error(f'{indent}Error message: {result.stderr.decode("utf-8")}')
                except subprocess.CalledProcessError as e:
                    self.log.error(f'{indent}Error updating EAD "{ead_id}" in ArcLight Solr: {e}')
        except Exception as e:
            self.log.error(f'{indent}Error writing to file {ead_file_path}: {e}')

    def delete_ead(self, ead_file_path, ead_id, indent=0):
        indent = ' ' * indent
        # delete from solr
        try:
            response = requests.post(
                f'{self.solr_url}/update?commit=true',
                json={'delete': {'id': ead_id}},
            )
            if response.status_code == 200:
                self.log.info(f'{indent}Deleted EAD "{ead_id}" from ArcLight Solr.')
                # delete ead file after suscessful deletion from solr
                try:
                    os.remove(ead_file_path)
                    self.log.info(f'{indent}Deleted file {ead_file_path}.')
                except FileNotFoundError:
                    self.log.error(f'{indent}File {ead_file_path} not found.')
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
        '--force-update',
        action='store_true',
        help='Force update of data',)
    parser.add_argument(
        '--solr-url',
        required=True,
        help='URL of the Solr core',)
    args = parser.parse_args()

    arcflow = ArcFlow(
        arclight_dir=args.arclight_dir,
        solr_url=args.solr_url,
        force_update=args.force_update)
    arcflow.run()

if __name__ == '__main__':
    main()