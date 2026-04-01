# MySQL Database Backup

This directory should contain an uncompressed MySQL dump file from ArchivesSpace.

## What's Included

This directory contains a minimal test SQL dump (`archivesspace.sql`) that allows the Docker environment to start successfully. This is intentionally minimal - ArchivesSpace will create its full schema on first startup.

**For production/development use**: Replace `archivesspace.sql` with a real database dump from your ArchivesSpace instance.

## How to Create a Real Backup

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

## What Should Be Here

This directory should contain:
- `archivesspace.sql` - Uncompressed MySQL database dump file

**Important**: The file must be named `archivesspace.sql` (uncompressed, not `.gz`)

## Restoration

When you run `docker compose up`, the `mysql-entrypoint.sh` script automatically:
1. Checks if `/var/lib/mysql/archivesspace` database exists in the container
2. If not, waits for MySQL to start
3. Creates the `archivesspace` database and `as` user
4. Imports everything from `backup-data/mysql/archivesspace.sql`

This allows you to reset to a clean state anytime by:
```bash
docker compose down -v
rm -rf mysql-data/
docker compose up -d
```

The database will be re-imported from the SQL dump file automatically.

## Test Dump

The included `archivesspace.sql` is a minimal test dump suitable for:
- Testing that the Docker environment starts correctly
- Verifying the import process works
- Running ArchivesSpace for the first time (it will initialize its schema)

It does **not** include:
- Any collection data
- User accounts beyond defaults
- Custom configuration

Replace it with your actual database dump for real use.
