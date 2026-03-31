# MySQL Database Backup

This directory should contain a complete MySQL data directory backup from ArchivesSpace.

## How to Create This Backup

See the main **LOCAL_TESTING_README.md**, section "Getting Data from Dev Server" for complete instructions.

### Quick Method (from dev server)

```bash
# On dev server - after importing SQL dump into Docker MySQL
docker compose up -d mysql
sleep 15

# Import your database dump
gunzip -c archivesspace.sql.gz | docker exec -i local-archivesspace-mysql mysql -u root -proot123 archivesspace

# Stop MySQL
docker compose down

# Copy the data directory to backup
sudo cp -r mysql-data/* backup-data/mysql/

# Clean working directory
rm -rf mysql-data/
```

## What Should Be Here

After extracting/copying, this directory should contain MySQL database files:
- `archivesspace/` - Database directory with table files
- `mysql/` - System database
- `performance_schema/` - Performance schema
- Other MySQL system directories

## Restoration

When you run `docker compose up`, the `mysql-entrypoint.sh` script automatically:
1. Checks if `/var/lib/mysql/archivesspace` exists in the container
2. If not, copies everything from this `backup-data/mysql` directory
3. Starts MySQL with the restored data

This allows you to reset to a clean state anytime by:
```bash
docker compose down -v
rm -rf mysql-data/
docker compose up -d
```
