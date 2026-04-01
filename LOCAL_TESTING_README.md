# Local ArchivesSpace & ArcLight Testing Environment

This is a complete local testing environment for ArchivesSpace 2.6, ArcLight 1.6.2, and associated Solr indexes. It allows you to test Archon migration tools and indexing changes without affecting the shared development server.

**Snapshot Date:** Can be updated from archivesspace-dev.library.illinois.edu

## What This Does

### TL;DR
In the root directory, run `./verify-setup.sh` then `docker compose up -d` to start:
- **MySQL 5.7**: Database for ArchivesSpace
- **ArchivesSpace 2.6**: Staff and public interfaces (custom-built from GitHub release)
- **Solr 8.11.3**: Search indexes with two cores (blacklight-core and archivesspace-solr)

Optionally add ArcLight 1.6.2 with: `docker compose --profile arclight up -d` (requires creating `arclight/Dockerfile`)

### More Details

This environment:
- Runs ArchivesSpace, MySQL, and Solr in Docker containers on your laptop
- Includes a minimal test database for immediate testing
- Can be populated with production-like data from the dev server
- Includes three main components:
  - **MySQL**: ArchivesSpace database with auto-import from SQL dump
  - **ArchivesSpace 2.6**: Custom-built from GitHub release (no Docker Hub image available for v2.6)
    - Staff interface: http://localhost:8080
    - Backend API: http://localhost:8089
    - Public interface: http://localhost:8081
  - **Solr**: Two cores for search (requires configsets from dev server):
    - `blacklight-core`: ArcLight search index
    - `archivesspace-solr`: ArchivesSpace index
- Automatically builds ArchivesSpace on first `docker compose build`
- Automatically restores MySQL database from `backup-data/mysql/archivesspace.sql` on first startup
- Uses Docker-managed volumes for data persistence (better permission handling)
- Lets you test migration and indexing changes safely - if you break it, just `docker compose down -v` and restart
- **Caution**: Don't delete the `backup-data` directory - it contains your clean snapshots

## Prerequisites

You need a container runtime installed on your computer. Choose one:

### Option 1: Rancher Desktop (Recommended - Free & Open Source)
- **Mac**: [Rancher Desktop for Mac](https://docs.rancherdesktop.io/getting-started/installation/#macos)
- **Windows**: [Rancher Desktop for Windows](https://docs.rancherdesktop.io/getting-started/installation/#windows)
- **Linux**: [Rancher Desktop for Linux](https://docs.rancherdesktop.io/getting-started/installation/#linux)

After installing, make sure to:
1. Open Rancher Desktop
2. In Preferences/Settings, ensure **dockerd (moby)** is selected as the container runtime (not containerd)
3. Enable "Support for docker compose"

### Option 2: Docker Desktop
- **Mac**: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- **Windows**: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)

Note: Docker Desktop requires a license for commercial use in larger organizations.

## Quick Start

### 1. Verify Prerequisites

Run the verification script to check your setup:

```bash
cd arcflow
./verify-setup.sh
```

This will:
- Check that Docker is installed and running
- Create `.env` file from `.env.example` if it doesn't exist
- Verify required files and directories are present
- Check line endings on shell scripts

**First-time setup**: The script will create a `.env` file with default test credentials. These are fine for local testing, but you can edit `.env` if needed.

### 2. Get the Files

Your folder should contain:

```
arcflow/
├── backup-data/
│   ├── mysql/                    # MySQL database backup (archivesspace.sql)
│   ├── archivesspace/           # ArchivesSpace data backup (optional)
│   ├── blacklight-core/         # ArcLight Solr core backup
│   └── archivesspace-solr/      # ArchivesSpace Solr core backup
├── configsets/
│   ├── blacklight-core/         # Solr config for ArcLight
│   └── archivesspace/           # Solr config for ArchivesSpace
├── archivesspace/
│   ├── Dockerfile               # Custom build for ArchivesSpace 2.6.0
│   └── docker-startup.sh        # Startup configuration script
├── .env                          # Environment variables (created by verify-setup.sh)
├── .env.example                  # Template for environment variables
├── docker-compose.yml
├── mysql-entrypoint.sh
├── solr-entrypoint.sh
├── verify-setup.sh
└── LOCAL_TESTING_README.md
```

**Test Data Included**: A minimal MySQL dump (`backup-data/mysql/archivesspace.sql`) is included for initial testing. This allows you to start the environment immediately.

**For Production Testing**: Replace the test dump with a real mysqldump from the dev server, and populate `configsets/` (see "Getting Data from Dev Server" below).

**Windows users**: If you downloaded as a ZIP file, the line endings in the entrypoint scripts might be incorrect. Run `./verify-setup.sh` to check, or see the Troubleshooting section.

### 3. Build and Start the Environment

**First time** (builds ArchivesSpace image):

```bash
cd arcflow
docker compose build
docker compose up -d
```

**Subsequent starts**:

```bash
cd arcflow
docker compose up -d
```

Wait about 60-90 seconds for all services to initialize. ArchivesSpace takes longer on first startup while it initializes the database.

You can monitor progress with:

```bash
docker compose logs -f
```

Press `Ctrl+C` to stop following logs.

### 4. Verify Services Are Running

Check that all services are healthy:

```bash
docker compose ps
```

You should see:
- `local-archivesspace-mysql` - healthy
- `local-archivesspace` - running (may show "health: starting" for first minute)
- `local-arclight-solr` - running

**Note**: Solr may show errors about missing cores if you haven't yet populated `configsets/` from the dev server. This is expected - MySQL and ArchivesSpace should still work.

### 5. Access the Interfaces

- **ArchivesSpace Staff Interface**: http://localhost:8080
  - Default login: `admin` / `admin` (or credentials from your backup)
- **ArchivesSpace Public Interface**: http://localhost:8081
- **ArchivesSpace API**: http://localhost:8089
- **Solr Admin**: http://localhost:8983/solr/
  - ArcLight core: http://localhost:8983/solr/blacklight-core
  - ArchivesSpace core: http://localhost:8983/solr/archivesspace-solr
- **MySQL**: `localhost:3306`
  - User: `as` / Password: `as123`
  - Database: `archivesspace`

### 6. (Optional) Start ArcLight

To run the ArcLight Rails application:

```bash
docker compose --profile arclight up -d
```

Access ArcLight at: http://localhost:3000

## Getting Data from Dev Server

You need to create backups from the dev server to populate your local environment. This section shows how to extract MySQL databases, ArchivesSpace data, and Solr indexes.

### Prerequisites for Data Extraction

- SSH access to `archivesspace-dev.library.illinois.edu`
- Sudo permissions on the dev server
- Enough local disk space (estimate ~5-10 GB depending on data size)

### Step 1: SSH to Dev Server

```bash
ssh archivesspace-dev.library.illinois.edu
```

### Step 2: Create Backup Directory

```bash
mkdir -p ~/aspace-backup
```

### Step 3: Backup MySQL Database

```bash
# Create MySQL dump (requires sudo or database credentials)
sudo mysqldump -u root -p archivesspace > ~/aspace-backup/archivesspace.sql

# Or if you know the ArchivesSpace database credentials:
mysqldump -u as -p archivesspace > ~/aspace-backup/archivesspace.sql

# Compress it
gzip ~/aspace-backup/archivesspace.sql
```

### Step 4: Backup Solr Cores

The Solr cores contain the search indexes. Create tarballs of each core:

```bash
# Backup blacklight-core (ArcLight index) - requires sudo
sudo tar -czf ~/aspace-backup/blacklight-core.tar.gz -C /var/solr/data blacklight-core

# Backup archivesspace Solr core - requires sudo
# Note: The core name might be different - check with: ls /var/solr/data/
sudo tar -czf ~/aspace-backup/archivesspace-solr.tar.gz -C /var/solr/data archivesspace

# Make the tarballs readable by your user
sudo chown $USER:$USER ~/aspace-backup/*.tar.gz
```

### Step 5: (Optional) Backup ArchivesSpace Data Directory

If you want to preserve uploaded files and other ArchivesSpace data:

```bash
# Find the ArchivesSpace data directory (typically /archivesspace/data or similar)
# This may vary based on your installation
sudo tar -czf ~/aspace-backup/archivesspace-data.tar.gz -C /path/to/archivesspace data

# Make readable
sudo chown $USER:$USER ~/aspace-backup/archivesspace-data.tar.gz
```

### Step 6: Verify Backups Created

```bash
ls -lh ~/aspace-backup/
```

You should see:
- `archivesspace.sql.gz` - MySQL database dump
- `blacklight-core.tar.gz` - ArcLight Solr index
- `archivesspace-solr.tar.gz` - ArchivesSpace Solr index
- `archivesspace-data.tar.gz` (optional) - ArchivesSpace data files

### Step 7: Copy Backups to Your Local Machine

**Exit from SSH** (or open a new terminal on your local machine):

**Mac/Linux:**

```bash
# Navigate to your arcflow directory
cd /path/to/arcflow

# Create backup-data directory structure
mkdir -p backup-data/mysql

# Download all backup files
scp archivesspace-dev.library.illinois.edu:~/aspace-backup/* .

# Extract MySQL backup to the mysql backup directory
gunzip -c archivesspace.sql.gz | mysql -h 127.0.0.1 -u root -proot123 archivesspace

# Or prepare the MySQL backup for import
mkdir -p backup-data/mysql-init
mv archivesspace.sql.gz backup-data/mysql-init/
```

**Windows (PowerShell):**

```powershell
cd \path\to\arcflow

# Create backup-data directory structure
New-Item -ItemType Directory -Force -Path backup-data\mysql

# Download all backup files
scp archivesspace-dev.library.illinois.edu:~/aspace-backup/* .
```

### Step 8: Extract Backups Locally

**Mac/Linux:**

```bash
# Extract Solr cores to backup-data
mkdir -p backup-data
tar -xzf blacklight-core.tar.gz -C backup-data/
tar -xzf archivesspace-solr.tar.gz -C backup-data/

# Extract ArchivesSpace data to backup-data (if you backed it up)
mkdir -p backup-data/archivesspace
tar -xzf archivesspace-data.tar.gz -C backup-data/archivesspace/

# Extract MySQL dump to backup-data/mysql
mkdir -p backup-data/mysql
gunzip -c archivesspace.sql.gz > backup-data/mysql/archivesspace.sql

# The MySQL entrypoint script will automatically import this on first startup

# Clean up downloaded tarballs
rm *.tar.gz *.sql.gz
```

**Windows (PowerShell):**

```powershell
# Extract Solr cores
New-Item -ItemType Directory -Force -Path backup-data
tar -xzf blacklight-core.tar.gz -C backup-data\
tar -xzf archivesspace-solr.tar.gz -C backup-data\

# Extract ArchivesSpace data
New-Item -ItemType Directory -Force -Path backup-data\archivesspace
tar -xzf archivesspace-data.tar.gz -C backup-data\archivesspace\

# Extract MySQL dump
New-Item -ItemType Directory -Force -Path backup-data\mysql

# Decompress SQL file
# If you have gunzip:
gunzip archivesspace.sql.gz
Move-Item archivesspace.sql backup-data\mysql\

# Or extract with tar if gunzip not available:
# tar -xzf archivesspace.sql.gz
# Move-Item archivesspace.sql backup-data\mysql\

# Clean up
Remove-Item *.tar.gz, *.sql.gz -ErrorAction SilentlyContinue
```

### Step 9: Clean Up on Dev Server

SSH back to the dev server and remove temporary files:

```bash
ssh archivesspace-dev.library.illinois.edu
rm -rf ~/aspace-backup
exit
```

### Step 10: Start Your Local Environment

Now that you have all backup data, start the full environment:

```bash
docker compose up -d
```

The entrypoint scripts will automatically:
- Import the MySQL database from `backup-data/mysql/archivesspace.sql` on first run
- Restore Solr cores from `backup-data/` directories

**Note**: The first startup may take 1-2 minutes as MySQL imports the database. Check logs with:
```bash
docker compose logs -f mysql
```

## Common Commands

All commands work in Terminal (Mac/Linux) or PowerShell/Command Prompt (Windows).

### Stop All Services

```bash
docker compose down
```

### Restart All Services

```bash
docker compose restart
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f archivesspace
docker compose logs -f mysql
docker compose logs -f solr
```

### Reset to Clean State

To restore everything to the original backup state:

```bash
# Stop all services and remove volumes
docker compose down -v

# Restart (will re-import from backup-data)
docker compose up -d
```

This deletes all Docker-managed volumes and restores from the backups in `backup-data/`. Note that with named volumes, you don't need to manually delete directories.

### Access MySQL Database

```bash
# Connect to MySQL
docker exec -it local-archivesspace-mysql mysql -u as -pas123 archivesspace

# Or with root
docker exec -it local-archivesspace-mysql mysql -u root -proot123

# Export a fresh database backup
docker exec local-archivesspace-mysql mysqldump -u root -proot123 archivesspace > my-backup.sql
```

### Index Data into Solr

Point your arcflow indexing scripts to:
- **ArcLight**: `http://localhost:8983/solr/blacklight-core`
- **ArchivesSpace**: `http://localhost:8983/solr/archivesspace-solr`

## Directory Structure

```
arcflow/
├── backup-data/              # Your clean snapshots (don't delete!)
│   ├── mysql/               # MySQL data directory backup
│   ├── archivesspace/       # ArchivesSpace data files (optional)
│   ├── blacklight-core/     # ArcLight Solr core snapshot
│   └── archivesspace-solr/  # ArchivesSpace Solr core snapshot
├── configsets/              # Solr configuration
│   ├── blacklight-core/     # Config for ArcLight core
│   └── archivesspace/       # Config for ArchivesSpace core
├── mysql-data/              # Working MySQL data (auto-created, can delete to reset)
├── archivesspace-data/      # Working ArchivesSpace data (auto-created)
├── solr-data/               # Working Solr data (auto-created, can delete to reset)
├── docker-compose.yml       # Docker configuration
├── mysql-entrypoint.sh      # MySQL restore script
├── solr-entrypoint.sh       # Solr restore script
└── README.md               # This file
```

**Important**: 
- `backup-data/` is read-only in containers and contains your clean state
- `mysql-data/`, `archivesspace-data/`, and `solr-data/` are working directories - safe to delete for reset
- Don't commit `backup-data/`, `*-data/` directories to git (they're in .gitignore)

## Updating Your Backup from Dev Server

To refresh your local backups with the latest data from the dev server, follow the complete process in the **"Getting Data from Dev Server"** section above. The key steps are:

1. Stop your local environment: `docker compose down -v`
2. Remove old backups: `rm -rf backup-data/*`
3. SSH to dev server and create fresh MySQL dump and Solr tarballs (Steps 1-6)
4. Copy files to local machine (Step 7)
5. Extract locally:
   ```bash
   mkdir -p backup-data/mysql
   gunzip -c archivesspace.sql.gz > backup-data/mysql/archivesspace.sql
   tar -xzf blacklight-core.tar.gz -C backup-data/
   tar -xzf archivesspace-solr.tar.gz -C backup-data/
   rm *.tar.gz *.sql.gz
   ```
6. Start environment: `docker compose up -d`

The MySQL database will be automatically imported from the new SQL dump file on startup.

## Troubleshooting

### "Port already in use" errors

Check if something else is using the ports:
- **8080, 8089**: Another ArchivesSpace instance
- **3306**: Another MySQL instance
- **8983**: Solr or SSH tunnel to dev server

Close those applications or change port mappings in `docker-compose.yml`.

### MySQL container won't start

Check logs: `docker logs local-archivesspace-mysql`

Common issues:
- Corrupted mysql-data directory - delete it and restart
- Permission issues with backup-data/mysql - ensure it's readable

### ArchivesSpace container exits immediately

Check logs: `docker logs local-archivesspace`

Common issues:
- MySQL not healthy yet - wait longer for MySQL to start
- Database connection issues - verify MySQL credentials

### Solr cores don't appear

Wait 15-20 seconds after startup, then check:

```bash
curl "http://localhost:8983/solr/admin/cores?action=STATUS"
```

Or check logs: `docker logs local-arclight-solr`

### "exec format error" on entrypoint scripts (Windows)

The shell scripts might have incorrect line endings (CRLF instead of LF).

**Fix in VS Code:**
1. Open `mysql-entrypoint.sh` and `solr-entrypoint.sh`
2. Click "CRLF" in the bottom-right corner
3. Select "LF"
4. Save files
5. Restart: `docker compose down && docker compose up -d`

**Fix in Notepad++:**
1. Open the files
2. Edit → EOL Conversion → Unix (LF)
3. Save
4. Restart containers

### Container name already in use

Remove the existing container:

```bash
docker rm -f local-archivesspace-mysql local-archivesspace local-arclight-solr
docker compose up -d
```

### Out of disk space

The backup data and working data can use significant disk space. To free up:

```bash
# Remove working data (will be restored from backup)
docker compose down -v
rm -rf mysql-data/ archivesspace-data/ solr-data/

# Remove unused Docker resources
docker system prune -a
```

## Architecture Notes

### Why This Setup?

- **Backup/Restore Pattern**: Working data in `*-data/` directories, clean snapshots in `backup-data/`
- **Custom Entrypoints**: Automatically restore from backup on first run
- **No Docker Volumes**: Uses bind mounts for easier access and backup
- **Production-like**: Same versions and configuration as dev/staging servers

### Service Dependencies

1. **MySQL** starts first (healthcheck ensures it's ready)
2. **ArchivesSpace** starts after MySQL is healthy
3. **Solr** starts independently (can run standalone)
4. **ArcLight** starts after Solr (optional, via profile)

### Data Flow

1. On first `docker compose up`, entrypoint scripts check for working data
2. If missing, they copy from `backup-data/` (read-only mount)
3. Services run using working data in `*-data/` directories
4. To reset: delete working data, restart - clean state restored automatically

## That's It!

- **To start**: `docker compose up -d`
- **To stop**: `docker compose down`
- **To reset**: Delete working data directories and restart
- **To update backups**: Follow "Getting Data from Dev Server" section
- **To add ArcLight**: `docker compose --profile arclight up -d`

The `backup-data/` folder contains your clean snapshots - **don't delete it** unless you're replacing with fresh backups!
