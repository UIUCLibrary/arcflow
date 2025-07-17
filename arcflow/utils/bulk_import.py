import glob
import os
import yaml
import json
import csv
import argparse
from asnake.client import ASnakeClient


def __get_asnake_client():
    """Function to create and return an ASnakeClient instance."""
    try:
        with open('.archivessnake.yml', 'r') as file:
            config = yaml.safe_load(file)
    except FileNotFoundError:
        print('File .archivessnake.yml not found. Create the file.')
        exit(0)

    try:
        client = ASnakeClient(
            username=config['username'],
            password=config['password'],
            baseurl=config['baseurl'],
        )
        client.authorize()
        return client
    except Exception as e:
        print(f'Error authorizing ASnakeClient: {e}')
        exit(0)

def get_ead_from_csv(csv_file):
    """Function to extract EAD ID from a CSV file."""
    try:
        with open(csv_file, 'r', encoding='utf8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                # Skip to third line
                if reader.line_num < 3:
                    continue
                if 'ead' in row:
                    return row['ead']
        return None
    except Exception as e:
        print(f'Error reading CSV file {csv_file}: {e}')
        return None

def get_resource_id_from_ead(ead_id, asnake_client):
    """Function to get resource ID from EAD ID."""
    try:
        search = asnake_client.get('/search',
            params={
                'page': 1,
                'q': f'"{ead_id}"',
                'type': ['resource'],
                'fields': ['id'],
            }
        ).json()

        if not search['results']:
            return None

        return search['results'][0]['id']
    except Exception as e:
        print(f'Error searching for resource ID: {e}')
        return None


def csv_bulk_import(csv_directory=None, load_type='ao', only_validate='false'):
    """Function to handle CSV bulk import."""
    print("Starting CSV bulk import...")
    if not csv_directory or not os.path.exists(csv_directory):
        print(f'Directory {csv_directory} does not exist. Exiting.')
        exit(0)

    client = __get_asnake_client()

    for f in glob.iglob(f'{csv_directory}*.csv'):
        print(f'Processing file {f}...')

        ead_id = get_ead_from_csv(f)
        if not ead_id:
            print(f'No EAD ID found in {f}.')
            continue
        
        resource_id = get_resource_id_from_ead(ead_id, client)
        if not resource_id:
            print(f'No resource found for EAD ID: {ead_id}.')
            continue

        parts = resource_id.split('/')
        if len(parts) < 4:
            print(f'Invalid resource ID format: {resource_id}.')
            continue
        repo = parts[2]
        rid = parts[4]

        if not repo or not rid:
            print(f'Invalid repository or resource ID extracted from {resource_id}.')
            continue

        file_list = []
        with open(f, 'rb') as file:
            file_list.append(('files[]', file.read()))

        import_job = client.post(
            f'/repositories/{ repo }/jobs_with_files',
            files=file_list,
            params={
                'job': json.dumps({
                    'job_type': 'bulk_import_job',
                    'job': {
                        'jsonmodel_type': 'bulk_import_job',
                        'resource_id': f'/repositories/{repo}/resources/{rid}',
                        'format': 'csv',
                        'content_type': 'csv',
                        'filename': os.path.basename(f),
                        'load_type': load_type,
                        'only_validate': only_validate,
                    },
                    'job_params': json.dumps({
                        'repo_id': f'{repo}',
                        # 'ref_id':'',
                        # 'position':'',
                        'type': 'resource',
                        'rid': f'{rid}',
                        # 'aoid':'',
                    }),
                }),
            }
        ).json()
        print(json.dumps(import_job, indent=4))


def main():
    parser = argparse.ArgumentParser(description='ArchivesSpace CSV Bulk Import Tool')
    parser.add_argument(
        '--dir',
        required=True,
        help='Path to CSV files directory',)
    parser.add_argument(
        '--load-type',
        default='ao',
        choices=['ao', 'digital', 'top_container_linker_job'],
        help='Type of load to perform (default: ao)',)
    parser.add_argument(
        '--only-validate',
        action='store_true',
        help='Force only validate',)
    args = parser.parse_args()

    csv_bulk_import(
        csv_directory=args.dir,
        load_type=args.load_type,
        only_validate='true' if args.only_validate else 'false')


if __name__ == '__main__':
    main()