# MySQL Database Backup

This directory contains a test MySQL dump file that provides a fully initialized ArchivesSpace database.

## What's Included

**Default**: `archivesspace.sql` - A complete ArchivesSpace v2.6.0 database dump with:
- Full database schema (120 migrations, 96 tables)
- Default admin user (admin/admin)
- Empty database with no collection data

This allows **immediate startup** without waiting 2-3 minutes for database initialization.

## Quick Start (Default Behavior)

```bash
docker compose up -d
# Wait ~60 seconds for services to start
# Access at http://localhost:8080 (admin/admin)
```

The included dump is imported automatically, giving you a working ArchivesSpace installation immediately.

## For Production/Development Use

To use real data from your ArchivesSpace instance, replace the test dump:

### How to Create a Real Backup

See the main **LOCAL_TESTING_README.md**, section "Getting Data from Dev Server" for complete instructions.

### Quick Method (from dev server)

```bash
# On dev server - create MySQL dump
sudo mysqldump -u root -p archivesspace > ~/aspace-backup/archivesspace.sql
gzip ~/aspace-backup/archivesspace.sql

# On local machine - replace test dump with real data
gunzip -c archivesspace.sql.gz > backup-data/mysql/archivesspace.sql
```

## Alternative: Fresh Installation Without Dump

To test the auto-initialization path (no dump file):

```bash
# Remove the test dump
rm backup-data/mysql/archivesspace.sql

# Start services (first startup takes 2-3 minutes)
docker compose down -v
docker compose up -d

# Watch the initialization process
docker compose logs -f archivesspace
```

You'll see ArchivesSpace run `setup-database.sh` automatically and create the schema.

## Restoration Behavior

**When `archivesspace.sql` exists (default):**
- `mysql-entrypoint.sh` imports the dump file on first startup (~5 seconds)
- ArchivesSpace detects schema exists and starts immediately
- Total startup time: ~60 seconds
- Results in: Fresh ArchivesSpace with empty data

**When `archivesspace.sql` does NOT exist:**
- MySQL creates an empty database
- ArchivesSpace auto-initializes schema on first startup (2-3 minutes)
- Total startup time: ~3 minutes
- Results in: Same fresh ArchivesSpace with empty data

Both paths give you the same working installation - the dump just makes it faster.

## Reset to Fresh Installation

```bash
docker compose down -v
docker compose up -d
```

- If dump file exists: Re-imports in ~60 seconds
- If no dump file: Re-initializes in ~3 minutes

## Creating Your Own Dump

After making changes to the database, save your state:

```bash
docker exec local-archivesspace-mysql mysqldump -u root -proot123 archivesspace > backup-data/mysql/archivesspace.sql
```

Now `docker compose down -v && docker compose up -d` will restore to this state.
