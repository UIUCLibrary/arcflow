"""Harvest classification data from ArchivesSpace and output nested JSON.

This script connects to an ArchivesSpace instance using ASnake, retrieves
resource records from one or more repositories, and builds a nested JSON
structure based on classification hierarchy (record groups, subgroups, collections).
"""

import os
import json
import yaml
import argparse
from asnake.client import ASnakeClient


def get_asnake_client():
    """Creates and returns an authenticated ASnakeClient.

    Loads credentials from .archivessnake.yml and authorizes the client.

    Returns:
        ASnakeClient: An authenticated ArchivesSpace client.

    Raises:
        SystemExit: If config file is missing or authentication fails.
    """
    try:
        with open('.archivessnake.yml', 'r') as file:
            config = yaml.safe_load(file)
    except FileNotFoundError:
        print('Error: .archivessnake.yml not found.')
        exit(1)

    try:
        client = ASnakeClient(
            username=config['username'],
            password=config['password'],
            baseurl=config['baseurl'],
        )
        client.authorize()
        return client
    except Exception as error:
        print(f'Error authorizing ASnakeClient: {error}')
        exit(1)


def labels_from_path(path_from_root):
    """Extracts record group and subgroup labels from a classification path.

    Args:
        path_from_root (list): List of classification nodes.

    Returns:
        tuple[str | None, str | None]: Record group label and subgroup label.
    """
    record_group = subgroup = None
    if path_from_root:
        rg_node = path_from_root[0]
        rg_id = rg_node.get('identifier')
        rg_title = rg_node.get('title')
        if rg_id and rg_title:
            record_group = f"{rg_id} — {rg_title}"

        if len(path_from_root) > 1:
            sg_node = path_from_root[1]
            sg_id = sg_node.get('identifier')
            sg_title = sg_node.get('title')
            code = f"{rg_id}.{sg_id}" if rg_id and sg_id else sg_id
            if code and sg_title:
                subgroup = f"{code} — {sg_title}"

    return record_group, subgroup


def parse_eadid(eadid):
    """Splits an EAD ID into its component parts.

    Args:
        eadid (str): EAD ID string (e.g., 'UI.12.3.45').

    Returns:
        tuple[str | None, str | None, str | None, str | None]: repo_code, rg_id, sg_id, col_id
    """
    parts = eadid.split('.')
    repo_code = parts[0] if len(parts) > 0 else None
    rg_id = parts[1] if len(parts) > 1 else None
    sg_id = parts[2] if len(parts) > 2 else None
    col_id = parts[3] if len(parts) > 3 else None
    return repo_code, rg_id, sg_id, col_id


def extract_labels(resource):
    """Extracts classification labels and metadata from a resource record.

    Args:
        resource (dict): A resource record from ArchivesSpace.

    Returns:
        tuple[str | None, str | None, str | None, str | None]: eadid, record_group_label, subgroup_label, title
    """
    eadid = resource.get('ead_id', '').strip()
    title = resource.get('title', '').strip()
    if not eadid:
        return None, None, None, None

    record_group_label = subgroup_label = None
    for link in resource.get('classifications', []):
        term = link.get('_resolved', {})
        path = term.get('path_from_root', [])
        rg, sg = labels_from_path(path)
        if rg:
            record_group_label = rg
        if sg:
            subgroup_label = sg

    if not record_group_label:
        return None, None, None, None

    return eadid, record_group_label, subgroup_label, title


def process_repository(repo_id, map_data, client):
    """Processes all resources in a repository and updates the nested map.

    Args:
        repo_id (str): Repository ID.
        map_data (dict): Nested classification map.
        client (ASnakeClient): Authenticated ArchivesSpace client.
    """
    resource_ids = client.get(f"/repositories/{repo_id}/resources?all_ids=true").json()
    for index, resource_id in enumerate(resource_ids):
        resource = client.get(
            f"/repositories/{repo_id}/resources/{resource_id}"
            "?resolve[]=classifications&resolve[]=classification_terms"
        ).json()

        eadid, rg_label, sg_label, title = extract_labels(resource)
        if not eadid or not rg_label:
            continue

        repo_code, rg_id, sg_id, col_id = parse_eadid(eadid)
        if not repo_code or not rg_id:
            continue

        repo = map_data.setdefault(repo_code, {})
        record_group = repo.setdefault(rg_id, {'label': rg_label, 'subgroups': {}})

        if sg_id:
            subgroup = record_group['subgroups'].setdefault(
                sg_id, {'label': sg_label, 'collections': {}}
            )
            if col_id:
                subgroup['collections'][eadid] = {'ead_id': eadid, 'title': title}
        else:
            record_group.setdefault('collections', {})[eadid] = {
                'ead_id': eadid,
                'title': title
            }

        print(f"[{index + 1}/{len(resource_ids)}] {eadid} -> RG={rg_label} SG={sg_label}")


def main():
    """Main entry point for harvesting classification data."""
    parser = argparse.ArgumentParser(
        description="Harvest classification data from ArchivesSpace."
    )
    parser.add_argument(
        '--repo-id',
        help='Repository ID to process. If omitted, all repositories will be processed.'
    )
    parser.add_argument(
        '--out',
        help='Output JSON file path. Should be app root.',
        default='./data/aspace_classification_map.json'
    )
    args = parser.parse_args()

    out_path = 'data/' + args.out
    repo_id = args.repo_id

    if os.path.exists(out_path):
        with open(out_path, 'r') as file:
            map_data = json.load(file)
    else:
        map_data = {}

    client = get_asnake_client()
    repo_ids = [repo_id] if repo_id else [
        repo['uri'].split('/')[-1] for repo in client.get('/repositories').json()
    ]

    for rid in repo_ids:
        print(f"Processing repository {rid}...")
        process_repository(rid, map_data, client)

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w') as file:
        json.dump(map_data, file, indent=2)
    print(f"Wrote {out_path} ({len(map_data)} repositories)")


if __name__ == "__main__":
    main()