import glob
import os
import yaml
import json
import csv
import argparse
import time
from pathlib import Path
from datetime import datetime
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

def report_csv_error(report_dict, error_string):
    """Function to print and log error messages (assumes only one error message)."""
    report_dict["error"] = error_string
    print(error_string)

def csv_bulk_import(csv_directory=None, load_type='ao', only_validate='false'):
    """Function to handle CSV bulk import."""
    print("Starting CSV bulk import...")
    if not csv_directory or not os.path.exists(csv_directory):
        print(f'Directory {csv_directory} does not exist. Exiting.')
        exit(0)

    client = __get_asnake_client()

    bulk_import_report = []

    for f in glob.iglob(f'{csv_directory}*.csv'):
        print(f'Processing file {f}...')
        file_import_report = {}
        file_import_report["identifier"] = Path(f).stem
        file_import_report["type"] = load_type
        file_import_report["only_validate"] = only_validate

        ead_id = get_ead_from_csv(f)
        file_import_report["ead_id"] = ead_id
        if not ead_id:
            report_csv_error(file_import_report, f'No EAD ID found in {f}.')
            bulk_import_report.append(file_import_report)
            continue
        
        resource_id = get_resource_id_from_ead(ead_id, client)
        file_import_report["resource_id"] = resource_id
        if not resource_id:
            report_csv_error(file_import_report, f'No resource found for EAD ID: {ead_id}.')
            bulk_import_report.append(file_import_report)
            continue

        parts = resource_id.split('/')
        if len(parts) < 4:
            report_csv_error(file_import_report, f'Invalid resource ID format: {resource_id}.')
            bulk_import_report.append(file_import_report)
            continue
        repo = parts[2]
        rid = parts[4]

        if not repo or not rid:
            report_csv_error(file_import_report, f'Invalid repository or resource ID extracted from {resource_id}.')
            bulk_import_report.append(file_import_report)
            continue
        file_import_report["repo_id"] = repo
        file_import_report["rid"] = rid

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
        file_import_report["results_status"] = import_job.get("status")
        file_import_report["results_id"] = import_job.get("id")
        file_import_report["results_uri"] = import_job.get("uri")
        file_import_report["results_warnings"] = import_job.get("warnings")

        bulk_import_report.append(file_import_report)
        print(json.dumps(import_job, indent=4))
    return bulk_import_report

def save_report(path, report_list, validate_only):
    """Function to create and save reports for tracking bulk imports."""
    current_datetime = datetime.now().strftime('%Y-%m-%d-%H%M%S')
    action = "validate" if validate_only else "import"
    suffix = current_datetime + "_" + action
    report_file_name_stem = Path(path).name + "_report_" + suffix
    report_text_file_name = report_file_name_stem + ".txt"
    report_save_path = os.path.join(path, "reports")

    if not os.path.exists(report_save_path):
        os.makedirs(report_save_path)

    txt_report_save_path = os.path.join(report_save_path, report_text_file_name)
    with open(txt_report_save_path, 'w', encoding='utf-8') as report:
        print("Import Job Info", file=report)
        json.dump(report_list, report, indent=4)

    report_csv_file_name = report_file_name_stem + ".csv"

    fieldnames = ['identifier','ead_id','repo_id', 'rid','only_validate','type','resource_id','error','results_status','results_warnings','results_id','results_uri']
    
    csv_report_save_path = os.path.join(report_save_path, report_csv_file_name)
    with open(csv_report_save_path, "w", newline="", encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in report_list:
            writer.writerow(row)

def check_job_status(client, repo_id, job_id):
    """Function to check whether a job has completed (and thus output files are ready)."""
    while True:
        job_status_response = client.get(f'/repositories/{repo_id}/jobs/{job_id}')
        job_status = job_status_response.json()['status']

        if job_status == 'completed':
            print(f"Job {job_id} completed successfully!")
            return True
        elif job_status == 'failed':
            print(f"Job {job_id} failed.")
            return False
        else:
            pause = 15
            print(f"Job {job_id} is still {job_status}. Waiting {pause} seconds...")
            time.sleep(pause)

def retrieve_job_output(path, report_list):
    """Function to retrieve and save last created output files for each job in the bulk import."""
    client = __get_asnake_client()
    for row in report_list:
        if "results_id" not in row:
            continue
        repo_id = row["repo_id"]
        job_id = row["results_id"]
        identifier = row["identifier"]
        if not check_job_status(client, repo_id, job_id):
            print(f"Error downloading files for job {job_id}")
            continue
        job_files = client.get(f"/repositories/{repo_id}/jobs/{job_id}/output_files").json()
        output_file_id = max(job_files)
        response = client.get(f"/repositories/{repo_id}/jobs/{job_id}/output_files/{output_file_id}")

        output_file_name = "_".join([identifier, "job", str(job_id), str(output_file_id)]) +".csv"
        
        if response.status_code == 200:
            output_save_path = os.path.join(path, "output")
            if not os.path.exists(output_save_path):
                os.makedirs(output_save_path)
            output_file_path = os.path.join(output_save_path, output_file_name)
            with open(output_file_path, "wb") as f:
                f.write(response.content)
            print(f"File {output_file_name} downloaded successfully.")
        else:
            print(f"Failed to retrieve file for identifier {identifier} and job id {job_id}. Status code: {response.status_code}")

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
    parser.add_argument(
        '--save-output-files',
        action='store_true',
        help='Download job output files',)
    args = parser.parse_args()

    import_report = csv_bulk_import(
        csv_directory=args.dir,
        load_type=args.load_type,
        only_validate='true' if args.only_validate else 'false')
    
    save_report(args.dir, import_report, args.only_validate)

    if args.save_output_files:
        retrieve_job_output(args.dir, import_report)

if __name__ == '__main__':
    main()