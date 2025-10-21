
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

def parse_eadid(eadid):
    parts = eadid.split('.')
    repo_code = parts[0] if len(parts) > 0 else None
    rg_id = parts[1] if len(parts) > 1 else None
    sg_id = parts[2] if len(parts) > 2 else None
    col_id = parts[3] if len(parts) > 3 else None
    return repo_code, rg_id, sg_id, col_id

def extract_labels(resource):
    eadid = resource.get('ead_id', '').strip()
    title = resource.get('title', '').strip()
    if not eadid:
        return None, None, None, None

    rg_label = sg_label = None
    for link in resource.get('classifications', []):
        term = link.get('_resolved', {})
        path = term.get('path_from_root', [])
        rg, sg = labels_from_path(path)
        if rg:
            rg_label = rg
        if sg:
            sg_label = sg

    return eadid, rg_label, sg_label, title

def process_repository(repo_id, map_data):
    ids = client.get(f"/repositories/{repo_id}/resources?all_ids=true").json()
    for i, id in enumerate(ids):
        res = client.get(f"/repositories/{repo_id}/resources/{id}?resolve[]=classifications&resolve[]=classification_terms").json()
        eadid, rg_label, sg_label, title = extract_labels(res)
        if not eadid:
            continue

        repo_code, rg_id, sg_id, col_id = parse_eadid(eadid)
        if not repo_code or not rg_id:
            continue

        repo = map_data.setdefault(repo_code, {})
        rg = repo.setdefault(rg_id, {'label': rg_label, 'subgroups': {}})

        if sg_id:
            sg = rg['subgroups'].setdefault(sg_id, {'label': sg_label, 'collections': {}})
            if col_id:
                sg['collections'][eadid] = {'ead_id': eadid, 'title': title}
        else:
            rg.setdefault('collections', {})[eadid] = {'ead_id': eadid, 'title': title}

        print(f"[{i+1}/{len(ids)}] {eadid} -> RG={rg_label} SG={sg_label}")

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
    print(f"Wrote {out_path} ({len(map_data)} repositories)")

if __name__ == "__main__":
    main()
