# MySQL Database Backup

This directory should contain an uncompressed MySQL dump file from ArchivesSpace.

## How to Create This Backup

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
