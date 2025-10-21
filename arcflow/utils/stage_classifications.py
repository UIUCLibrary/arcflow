import os
import json
import yaml
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

client = __get_asnake_client()

def labels_from_path(path_from_root):
    """
    Extracts human-readable labels for record groups and subgroups from a classification path.
    Returns a tuple: (record group label, subgroup label)
    """
    rg = sg = None
    if path_from_root:
        rg_node = path_from_root[0]
        rg_id = rg_node.get('identifier')
        rg_t = rg_node.get('title')
        if rg_id and rg_t:
            rg = f"{rg_id} — {rg_t}"

        if len(path_from_root) > 1:
            sg_node = path_from_root[1]
            sg_id = sg_node.get('identifier')
            sg_t = sg_node.get('title')
            code = f"{rg_id}.{sg_id}" if rg_id and sg_id else sg_id
            if code and sg_t:
                sg = f"{code} — {sg_t}"
    return rg, sg

def extract_rg_sg(resource):
    """
    Given a resource record, extracts its EAD ID and associated record group and subgroup labels.
    Returns a tuple: (eadid, list of record groups, list of subgroups)
    """
    eadid = resource.get('ead_id', '').strip()
    if not eadid:
        return None, [], []

    rgs, sgs = [], []
    for link in resource.get('classifications', []):
        term = link.get('_resolved', {})
        path = term.get('path_from_root', [])
        rg, sg = labels_from_path(path)
        if rg:
            rgs.append(rg)
        if sg:
            sgs.append(sg)

    return eadid, list(set(rgs)), list(set(sgs))

def process_repository(repo_id, map_data):
    """
    Processes all resources in a given repository and updates the flat map_data structure.
    """
    ids = client.get(f"/repositories/{repo_id}/resources?all_ids=true").json()
    for i, id in enumerate(ids):
        res = client.get(f"/repositories/{repo_id}/resources/{id}?resolve[]=classifications&resolve[]=classification_terms").json()
        eadid, rgs, sgs = extract_rg_sg(res)
        if not eadid:
            continue
        map_data[eadid] = {
            'record_groups': rgs,
            'subgroups': sgs
        }

        print(f"[{i+1}/{len(ids)}] {eadid} -> RG={rgs} SG={sgs}")

def main():
    parser = argparse.ArgumentParser(description="Harvest classification data from ArchivesSpace.")
    parser.add_argument('--repo-id', help='Repository ID to process. If omitted, all repositories will be processed.')
    parser.add_argument('--out', help='Output JSON file path.', default='./aspace_classification_map.json')
    args = parser.parse_args()

    out_path = args.out
    repo_id = args.repo_id

    if os.path.exists(out_path):
        with open(out_path, 'r') as f:
            map_data = json.load(f)
    else:
        map_data = {}

    repo_ids = [repo_id] if repo_id else [repo['uri'].split('/')[-1] for repo in client.get('/repositories').json()]

    for rid in repo_ids:
        print(f"Processing repository {rid}...")
        process_repository(rid, map_data)

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w') as f:
        json.dump(map_data, f, indent=2)
    print(f"Wrote {out_path} ({len(map_data)} records)")

if __name__ == "__main__":
    main()