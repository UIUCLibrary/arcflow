# Blacklight-Core Solr Index Backup

This directory should contain the Solr core data for the ArcLight search index.

## How to Create This Backup

From the dev server:

```bash
# SSH to dev server
ssh archivesspace-dev.library.illinois.edu

# Create tarball of blacklight-core
sudo tar -czf ~/blacklight-core.tar.gz -C /var/solr/data blacklight-core
sudo chown $USER:$USER ~/blacklight-core.tar.gz

# Exit and download locally
exit
scp archivesspace-dev.library.illinois.edu:~/blacklight-core.tar.gz .

# Extract to backup-data
tar -xzf blacklight-core.tar.gz -C backup-data/
rm blacklight-core.tar.gz
```

## What Should Be Here

This directory should contain the complete Solr core structure:
```
blacklight-core/
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
rm -rf solr-data/blacklight-core
docker compose up -d
```
