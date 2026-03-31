# ArchivesSpace Solr Index Backup

This directory should contain the Solr core data for the ArchivesSpace search index.

## How to Create This Backup

From the dev server:

```bash
# SSH to dev server
ssh archivesspace-dev.library.illinois.edu

# Create tarball of archivesspace Solr core
# Note: The core name might vary - check with: ls /var/solr/data/
sudo tar -czf ~/archivesspace-solr.tar.gz -C /var/solr/data archivesspace
sudo chown $USER:$USER ~/archivesspace-solr.tar.gz

# Exit and download locally
exit
scp archivesspace-dev.library.illinois.edu:~/archivesspace-solr.tar.gz .

# Extract to backup-data
tar -xzf archivesspace-solr.tar.gz -C backup-data/
# Rename if needed to match docker-compose.yml
mv backup-data/archivesspace backup-data/archivesspace-solr
rm archivesspace-solr.tar.gz
```

## What Should Be Here

This directory should contain the complete Solr core structure:
```
archivesspace-solr/
├── conf/               # Solr configuration (if not using configsets)
├── core.properties     # Core properties file
└── data/
    ├── index/          # Lucene index files
    ├── tlog/           # Transaction logs
    └── snapshot_metadata/
```

## Restoration

The `solr-entrypoint.sh` script automatically restores this core on container startup if the working index is missing.

To reset the index:
```bash
docker compose down
rm -rf solr-data/archivesspace-solr
docker compose up -d
```
