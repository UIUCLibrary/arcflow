# MySQL Database Backup

This directory is for an optional MySQL dump file from ArchivesSpace.

## What's Included

This directory is **empty by default**. When you run `docker compose up` for the first time:
- MySQL creates an empty `archivesspace` database  
- ArchivesSpace automatically runs its `setup-database.sh` script to initialize the schema (takes 2-3 minutes)
- Default admin user (admin/admin) is created
- All migrations are applied

This gives you a **fresh, working ArchivesSpace installation** with no data.

## For Production/Development Use

To use real data from your ArchivesSpace instance, place a MySQL dump file here and it will be imported instead of creating a fresh installation.

### How to Create a Real Backup

See the main **LOCAL_TESTING_README.md**, section "Getting Data from Dev Server" for complete instructions.

### Quick Method (from dev server)

```bash
# On dev server - create MySQL dump
sudo mysqldump -u root -p archivesspace > ~/aspace-backup/archivesspace.sql
gzip ~/aspace-backup/archivesspace.sql

# On local machine - extract to backup directory
mkdir -p backup-data/mysql
gunzip -c archivesspace.sql.gz > backup-data/mysql/archivesspace.sql
```

## What Can Be Here

This directory can optionally contain:
- `archivesspace.sql` - Uncompressed MySQL database dump file

**Important**: If present, the file must be named `archivesspace.sql` (uncompressed, not `.gz`)

## Restoration Behavior

**When `archivesspace.sql` exists:**
- `mysql-entrypoint.sh` imports the dump file on first startup
- ArchivesSpace uses the imported database  
- Results in a copy of your production/dev data

**When `archivesspace.sql` does NOT exist (default):**
- MySQL creates an empty database
- ArchivesSpace auto-initializes schema on first startup (takes 2-3 minutes)
- Results in a fresh installation with default admin user (admin/admin)

## Reset to Fresh Installation

To reset to a clean state:

```bash
docker compose down -v
docker compose up -d
```

- If you have an SQL dump file, it re-imports it
- If you don't have an SQL dump file, ArchivesSpace reinitializes a fresh installation
