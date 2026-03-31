# ArcFlow

Code for exporting data from ArchivesSpace to ArcLight, along with additional utility scripts for data handling and transformation.

## Local Testing Environment

For local testing of Archon migration and indexing, you can run a complete environment with ArchivesSpace 2.6, MySQL, and Solr in Docker containers. This provides a clean, isolated environment that can be reset to a known state.

### Quick Start

```bash
# Verify your setup
./verify-setup.sh

# Start all services
docker compose up -d

# Access:
# - ArchivesSpace: http://localhost:8080
# - Solr Admin: http://localhost:8983/solr/
# - MySQL: localhost:3306
```

### Documentation

- **[LOCAL_TESTING_README.md](LOCAL_TESTING_README.md)** - Complete setup guide with dev server data extraction
- **[docs/LOCAL_TESTING_QUICK_START.md](docs/LOCAL_TESTING_QUICK_START.md)** - Quick reference for daily use
- **[docs/LOCAL_SOLR_SETUP.md](docs/LOCAL_SOLR_SETUP.md)** - Original Solr-only setup (legacy)

### What's Included

- **ArchivesSpace 2.6** with MySQL database
- **Solr 8.11.3** with two cores:
  - `blacklight-core` - ArcLight search index
  - `archivesspace-solr` - ArchivesSpace index
- **MySQL 5.7** - Database for ArchivesSpace
- **Backup/Restore** - Clean state restoration from `backup-data/` directory

## Local Development

### Testing with Local Solr (Legacy)

For local testing of indexing without affecting shared development environments, you can run ArcLight Solr in a Docker container. See [docs/LOCAL_SOLR_SETUP.md](docs/LOCAL_SOLR_SETUP.md) for detailed instructions.

Quick start:
```bash
./scripts/setup-local-solr.sh
```