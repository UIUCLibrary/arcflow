# ArchivesSpace 2.6.0 Docker Build

This directory contains the Dockerfile and startup script for building a custom ArchivesSpace 2.6.0 Docker image.

## Why a Custom Build?

ArchivesSpace did not publish Docker images to Docker Hub until version 4.0. For version 2.6.0, we build a custom image from the official GitHub release.

## What's Included

- **Dockerfile**: Downloads the v2.6.0 release zip from GitHub and sets up ArchivesSpace
- **docker-startup.sh**: Configures database connection and starts ArchivesSpace

## Build Process

The Dockerfile:
1. Uses OpenJDK 8 (required for ArchivesSpace 2.6.0)
2. Downloads archivesspace-v2.6.0.zip from GitHub releases
3. Installs MySQL connector for database support
4. Configures user permissions and healthchecks

The startup script:
1. Reads environment variables for database configuration
2. Disables embedded Solr (using external Solr container)
3. Starts ArchivesSpace

## Usage

The image is built automatically when you run:
```bash
docker compose build archivesspace
```

Or when first starting the stack:
```bash
docker compose up -d
```

## Environment Variables

Configured in docker-compose.yml:
- `ARCHIVESSPACE_DB_TYPE`: Database type (mysql)
- `ARCHIVESSPACE_DB_HOST`: MySQL hostname
- `ARCHIVESSPACE_DB_PORT`: MySQL port
- `ARCHIVESSPACE_DB_NAME`: Database name
- `ARCHIVESSPACE_DB_USER`: Database username
- `ARCHIVESSPACE_DB_PASS`: Database password
- `ASPACE_JAVA_XMX`: Java memory settings

## Source

- Release: https://github.com/archivesspace/archivesspace/releases/tag/v2.6.0
- Official Dockerfile reference: https://github.com/archivesspace/archivesspace/blob/v2.6.0/Dockerfile
