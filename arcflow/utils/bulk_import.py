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
from multiprocessing.pool import ThreadPool as Pool
import re


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

def check_for_children(repo_id, rid, asnake_client):
    """Function to check how many top-level children a resource already has. Returns integer value for the number of children or -1 if encounters an error."""
    try:
        info = asnake_client.get(f"/repositories/{repo_id}/resources/{rid}/tree/root").json()
        if 'child_count' not in info:
            return -1

        return int(info['child_count'])
    except Exception as e:
        print(f'Error retrieving child count for resource ID: {e}')
        return -1

def delete_archival_object(repo_id, ao_id, asnake_client):
    """
    Function to delete an archival object by ID. 
    Returns True if successful, False otherwise.
    """
    try:
        delete_response = asnake_client.delete(
            f"/repositories/{repo_id}/archival_objects/{ao_id}")
        if delete_response.status_code == 200:
            print(f"Deleted archival object {ao_id} successfully.")
            return True
        else:
            print(f"Failed to delete archival object {ao_id}. Status code: {delete_response.status_code}")
            return False
    except Exception as e:
        print(f'Error deleting archival object ID {ao_id}: {e}')
        return False

def delete_children(repo_id, rid, asnake_client):
    """
    Function to delete all top-level children of a resource. 
    Returns integer value for the number of children deleted or -1 if encounters an error.
    """
    try:
        info = asnake_client.get(f"/repositories/{repo_id}/resources/{rid}/tree/root").json()
        child_count = int(info.get('child_count', 0))
        if child_count > 0:
            with Pool(processes=10) as pool:
                waypoints = int(info.get('waypoints', 0))
                # in case there are more children than the precomputed_waypoints
                # starting with the highest waypoint and working backwards to avoid the list shrinking and changing offsets for remaining waypoints
                for i in range(waypoints, 1, -1):
                    waypoint = asnake_client.get(f"/repositories/{repo_id}/resources/{rid}/tree/waypoint",
                        params={
                            'offset': i-1,
                    }).json()
                    results = [pool.apply_async(
                        delete_archival_object, 
                        args=(repo_id, child['uri'].split('/')[-1], asnake_client)) 
                        for child in waypoint]
                    # wait for task to complete
                    for r in results:
                        r.get()

                # then delete the remaining children in the precomputed_waypoints
                results = [pool.apply_async(
                    delete_archival_object, 
                    args=(repo_id, child['uri'].split('/')[-1], asnake_client)) 
                    for child in info['precomputed_waypoints']['']['0']]
                # wait for task to complete
                for r in results:
                    r.get()
        return child_count
    except Exception as e:
        print(f'Error deleting children for resource ID: {e}')
        return -1

def report_csv_error(report_dict, error_string):
    """Function to print and log error messages (assumes only one error message)."""
    report_dict["error"] = error_string
    print(error_string)

def csv_bulk_import(
        csv_directory=None, 
        load_type='ao', 
        only_validate='false', 
        save_output_files=False,
        overwrite_children=False,
        only_delete_children=False,
        report_text_file=""):
    """Function to handle CSV bulk import."""
    if report_text_file:
        print(f"Retrying CSV bulk import with report file {report_text_file}...")
    else:
        print("Starting CSV bulk import...")

    if not csv_directory or not os.path.exists(csv_directory):
        print(f'Directory {csv_directory} does not exist. Exiting.')
        exit(0)

    client = __get_asnake_client()
    aspace_instance_url = client.config['baseurl'].split(":")[1].lstrip("/")

    bulk_import_report = []

    if report_text_file:
        try:
            with open(report_text_file, "r") as file:
                entries = yaml.safe_load(file)
        except FileNotFoundError:
            print(f"File {report_text_file} not found.")
            exit(0)
    else:
        entries = glob.iglob(f'{csv_directory}*.csv')

    for f in entries:
        if report_text_file:
            if f.get("java_mysql_error", 0) > 0:
                f = f"{csv_directory}{f['identifier']}.csv"
                print(f'Retrying file {f}...')
            else:
                continue
        else:
            print(f'Processing file {f}...')

        file_import_report = {}
        file_import_report["identifier"] = Path(f).stem
        file_import_report["type"] = load_type
        file_import_report['aspace_url'] = aspace_instance_url
        file_import_report["only_validate"] = only_validate
        file_import_report["import_date"] = datetime.now().strftime('%Y-%m-%d')

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

        if load_type == "ao":
            if overwrite_children or only_delete_children:
                deleted_children = delete_children(repo, rid, client)
                file_import_report["deleted_children"] = deleted_children
                if deleted_children == -1:
                    report_csv_error(file_import_report, f'Error deleting children for EAD ID {ead_id}. Not imported.')
                    bulk_import_report.append(file_import_report)
                    continue
                if only_delete_children:
                    file_import_report["results_status"] = "Completed"
                    file_import_report["results_warnings"] = f"Deleted {deleted_children} children. No import performed."
                    bulk_import_report.append(file_import_report)
                    continue
            else:
                child_count = check_for_children(repo, rid, client)
                if child_count > 0:
                    report_csv_error(file_import_report, f'EAD ID {ead_id} already has {child_count} top-level children in ASpace. Not imported.')
                    bulk_import_report.append(file_import_report)
                    continue
                elif child_count == -1:
                    report_csv_error(file_import_report, f'Error checking children for EAD ID {ead_id}. Not imported.')
                    bulk_import_report.append(file_import_report)
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
        file_import_report["results_status"] = import_job.get("status")
        file_import_report["results_id"] = import_job.get("id")
        file_import_report["results_uri"] = import_job.get("uri")
        file_import_report["results_warnings"] = import_job.get("warnings")

        bulk_import_report.append(file_import_report)
        print(json.dumps(import_job, indent=4))

    if not bulk_import_report:
        print("No more files to process. Exiting.")
        exit(0)
    
    if save_output_files:
        try:
            retrieve_job_output(csv_directory, bulk_import_report, client)
        except Exception as e:
            print(f"Error while retrieving job ouput: {e}")
    
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
        print("# Import Job Info", file=report)
        json.dump(report_list, report, indent=4)

    report_csv_file_name = report_file_name_stem + ".csv"

    fieldnames = ['identifier','ead_id','aspace_url','import_date','repo_id', 'rid', 'only_validate','type','resource_id','error','results_status','results_warnings','results_id','results_uri','deleted_children']
    issue_assessment_fieldnames = get_issue_assessment_fieldnames()
    fieldnames.extend(issue_assessment_fieldnames)
    
    csv_report_save_path = os.path.join(report_save_path, report_csv_file_name)
    with open(csv_report_save_path, "w", newline="", encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in report_list:
            writer.writerow(row)

    return f"{report_save_path}/{report_text_file_name}"

def check_job_status(asnake_client, repo_id, job_id):
    """Function to check whether a job has completed (and thus output files are ready)."""
    while True:
        job_status_response = asnake_client.get(f'/repositories/{repo_id}/jobs/{job_id}')
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

def retrieve_job_output(path, report_list, asnake_client):
    """Function to retrieve and save last created output files for each job in the bulk import."""
    total_count = len(report_list)
    count = 0
    for row in report_list:
        count += 1
        ead_id = row.get("ead_id","")
        identifier = row.get("identifier","")
        if "results_id" not in row:
            print(f"No job output to retrive for {ead_id} ({identifier}), finding aid csv {count} out of {total_count}")
            continue
        repo_id = row.get("repo_id",0)
        job_id = row.get("results_id",0)
        print(f"Retrieving job output for {ead_id} ({identifier}), finding aid csv {count} out of {total_count}")
        if not check_job_status(asnake_client, repo_id, job_id):
            print(f"Error downloading files for job {job_id}")
            continue
        job_files = asnake_client.get(f"/repositories/{repo_id}/jobs/{job_id}/output_files").json()
        output_file_id = max(job_files)
        response = asnake_client.get(f"/repositories/{repo_id}/jobs/{job_id}/output_files/{output_file_id}")

        output_file_name = "_".join([identifier, "job", str(job_id), str(output_file_id)]) +".csv"
        
        if response.status_code == 200:
            output_save_path = os.path.join(path, "output")
            if not os.path.exists(output_save_path):
                os.makedirs(output_save_path)
            output_file_path = os.path.join(output_save_path, output_file_name)
            with open(output_file_path, "wb") as f:
                f.write(response.content)
            print(f"File {output_file_name} downloaded successfully.")
            issue_total_count = check_job_output("Info or Error",output_file_path)
            row["csv_issue_count"] = issue_total_count
            determine_issue_types(row, issue_total_count, output_file_path)
        else:
            report_csv_error(row, f"Failed to retrieve file for identifier {identifier} and job id {job_id}. Status code: {response.status_code}")

def check_job_output(column_heading, file_path, pattern=""):
    """Function to check whether any data was logged in a specified column of a CSV at a given path, and if so how many rows have data in them. Returns -1 for errors."""
    
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' does not exist.")
        return -1

    try:
        with open(file_path, mode='r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)

            if column_heading not in reader.fieldnames:
                print(f"Error: Column {column_heading} not found in the CSV file.")
                return -1

            count = 0
            for row in reader:
                value = row.get(column_heading)
                if value and value.strip():
                    if pattern == "":
                        count += 1
                    else:
                        pattern_match = re.match(pattern, value)
                        if pattern_match: count += 1
            return count

    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except PermissionError:
        print(f"Error: Permission denied when trying to read '{file_path}'.")
    except csv.Error as e:
        print(f"Error reading CSV file at '{file_path}': {e}")
    except Exception as e:
        print(f"An unexpected error occurred with '{file_path}': {e}")

    return -1

def determine_issue_types(csv_info, issue_total_count, job_output_file_path):
    """Function to check rows of the job output file for specific types of issues. Modifies the csv info dictionary to log this data and calculates the number of issues not accounted for."""
    issue_types = get_job_issue_types()
    found_issues = 0
    for issue, value in issue_types.items():
        issue_count = check_job_output("Info or Error",job_output_file_path,value)
        csv_info[issue] = issue_count
        found_issues += issue_count

    csv_info["unaccounted for issues"] = issue_total_count - found_issues

def get_job_issue_types():
    """Function to return a dictionary of common issues found in job output, with regular expressions to match"""
    return {
        "csv_issue_count_top_container": r"Top Container \[.+\]( would be)? created",
        "csv_issue_count_unable_container": r"Unable to create Container Instance .+: \[undefined method",
        "java_mysql_error": r"(.+)?Java::ComMysqlJdbcExceptionsJdbc4::MySQLTransactionRollbackException:",
        "count_not_processed_parent_error": r".+will not be processed due to errors: The parent archival object was not created"
    }

def get_issue_assessment_fieldnames():
    """Function to return the dictionary keys added to the csv_rows in the determine_issue_types() function"""
    issue_fieldnames = ["csv_issue_count"]
    issue_fieldnames.extend(list(get_job_issue_types().keys()))
    issue_fieldnames.append("unaccounted for issues")
    return issue_fieldnames

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
    parser.add_argument(
        '--overwrite-children',
        action='store_true',
        help='Overwrite/delete existing children during import/validation',)
    parser.add_argument(
        '--only-delete-children',
        action='store_true',
        help='Only delete existing children without performing import',)
    parser.add_argument(
        '--max-retries',
        type=int,
        default=0,
        help='Number of times to retry a failed job (default: 0)',)
    args = parser.parse_args()

    if not args.dir.endswith('/'):
        args.dir += '/'

    report_text_file = ""
    is_retrying = args.max_retries > 0
    while True:
        if args.max_retries < 0:
            if is_retrying:
                print("Maximum retries reached. Exiting.")
            break
        else:
            import_report = csv_bulk_import(
                csv_directory=args.dir,
                load_type=args.load_type,
                only_validate='true' if args.only_validate else 'false',
                save_output_files=args.save_output_files,
                overwrite_children=args.overwrite_children,
                only_delete_children=args.only_delete_children,
                report_text_file=report_text_file)

            report_text_file = save_report(args.dir, import_report, args.only_validate)

            args.max_retries -= 1

if __name__ == '__main__':
    main()