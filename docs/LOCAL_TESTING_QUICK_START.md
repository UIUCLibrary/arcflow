# Quick Start: Local Testing Environment

This is a quick reference for getting the local ArchivesSpace + ArcLight testing environment running.

## Prerequisites

- Docker or Rancher Desktop installed
- SSH access to `archivesspace-dev.library.illinois.edu`
- Sudo permissions on dev server

## First Time Setup

### 1. Get Backup Data from Dev Server

```bash
# SSH to dev server
ssh archivesspace-dev.library.illinois.edu

# Create backup directory
mkdir -p ~/aspace-backup

# Backup MySQL database
sudo mysqldump -u root archivesspace | gzip > ~/aspace-backup/archivesspace.sql.gz

# Backup Solr cores
sudo tar -czf ~/aspace-backup/blacklight-core.tar.gz -C /var/solr/data blacklight-core
sudo tar -czf ~/aspace-backup/archivesspace-solr.tar.gz -C /var/solr/data archivesspace

# Make readable
sudo chown $USER:$USER ~/aspace-backup/*

# Exit SSH
exit
```

### 2. Copy Backups Locally

```bash
# On your local machine
cd /path/to/arcflow

# Download backups
scp archivesspace-dev.library.illinois.edu:~/aspace-backup/* .

# Create backup structure
mkdir -p backup-data/mysql

# Extract Solr cores
tar -xzf blacklight-core.tar.gz -C backup-data/
tar -xzf archivesspace-solr.tar.gz -C backup-data/

# Extract MySQL dump (uncompressed)
gunzip -c archivesspace.sql.gz > backup-data/mysql/archivesspace.sql

# Cleanup
rm *.tar.gz *.sql.gz
```

### 3. Get Solr Configsets

```bash
# Option A: From dev server
ssh archivesspace-dev.library.illinois.edu
sudo tar -czf ~/bl-config.tar.gz -C /var/solr/data/blacklight-core conf
sudo tar -czf ~/as-config.tar.gz -C /var/solr/data/archivesspace conf
sudo chown $USER:$USER ~/*.tar.gz
exit

scp archivesspace-dev.library.illinois.edu:~/*-config.tar.gz .
mkdir -p configsets/blacklight-core configsets/archivesspace
tar -xzf bl-config.tar.gz -C configsets/blacklight-core/
tar -xzf as-config.tar.gz -C configsets/archivesspace/
rm *-config.tar.gz

# Option B: From ArcLight gem (for blacklight-core)
cd /path/to/arcuit
ARCLIGHT_PATH=$(bundle show arclight)
cp -r "${ARCLIGHT_PATH}/solr/config" /path/to/arcflow/configsets/blacklight-core
```

### 4. Start Everything

```bash
docker compose up -d
```

Wait 30-60 seconds, then access:
- **ArchivesSpace Staff**: http://localhost:8080 (admin/admin)
- **ArchivesSpace API**: http://localhost:8089
- **Solr Admin**: http://localhost:8983/solr/

## Daily Use

### Start Services
```bash
docker compose up -d
```

### Stop Services
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f
# Or specific service:
docker compose logs -f archivesspace
```

### Reset to Clean State
```bash
docker compose down -v
rm -rf mysql-data/ archivesspace-data/ solr-data/
docker compose up -d
```

### Access MySQL
```bash
docker exec -it local-archivesspace-mysql mysql -u as -pas123 archivesspace
```

### Check Service Health
```bash
docker compose ps
```

## Update Backups from Dev Server

To get fresh data:

```bash
# Stop local environment
docker compose down -v
rm -rf backup-data/*

# Follow "Get Backup Data from Dev Server" steps above
# Then start fresh
docker compose up -d
```

## Ports

| Service | Port | URL |
|---------|------|-----|
| MySQL | 3306 | localhost:3306 |
| ArchivesSpace Staff | 8080 | http://localhost:8080 |
| ArchivesSpace Public | 8081 | http://localhost:8081 |
| ArchivesSpace API | 8089 | http://localhost:8089 |
| Solr Admin | 8983 | http://localhost:8983/solr/ |
| ArcLight (optional) | 3000 | http://localhost:3000 |

## Troubleshooting

### Port conflicts
Change ports in `docker-compose.yml` or stop conflicting services

### Services won't start
```bash
docker compose down -v
docker system prune
docker compose up -d
```

### Need clean database
```bash
docker compose down
rm -rf mysql-data/
docker compose up -d
```

### Need clean Solr
```bash
docker compose down
rm -rf solr-data/
docker compose up -d
```

## Full Documentation

See **LOCAL_TESTING_README.md** for complete documentation including:
- Detailed backup procedures
- Windows-specific instructions
- Comprehensive troubleshooting
- Architecture details
