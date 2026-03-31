# ArchivesSpace Data Directory Backup (Optional)

This directory is optional and contains ArchivesSpace application data such as:
- Uploaded files
- Generated reports  
- Export files
- Other application data

## When You Need This

You typically only need this backup if:
- You have important uploaded files (digital objects, PDFs, etc.)
- You want to preserve generated reports
- You're testing file upload functionality

For most migration testing, the MySQL database backup is sufficient.

## How to Create This Backup

If you determine you need this backup:

```bash
# SSH to dev server
ssh archivesspace-dev.library.illinois.edu

# Find the ArchivesSpace data directory
# Common locations: /archivesspace/data, /opt/archivesspace/data
# Or check: ps aux | grep archivesspace

# Create tarball (adjust path as needed)
sudo tar -czf ~/archivesspace-data.tar.gz -C /path/to/archivesspace data
sudo chown $USER:$USER ~/archivesspace-data.tar.gz

# Exit and download
exit
scp archivesspace-dev.library.illinois.edu:~/archivesspace-data.tar.gz .

# Extract
tar -xzf archivesspace-data.tar.gz -C backup-data/archivesspace/
rm archivesspace-data.tar.gz
```

## What Should Be Here

```
archivesspace/
└── data/
    ├── export/
    ├── indexer_state/
    ├── tmp/
    └── other application files
```

## Note

This backup is currently NOT used by the docker-compose setup. If you need it, you'll need to modify the ArchivesSpace volume mount in `docker-compose.yml`.
