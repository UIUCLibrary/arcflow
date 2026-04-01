# Quick Test Guide - Verify Working Setup

This guide shows you exactly what was tested and verified working.

## What's Working (Verified 2026-04-01)

All services start successfully and respond with HTTP 200:

```
✅ MySQL (3306) - 96 tables, schema v120
✅ ArchivesSpace Backend API (8089) - Returns version JSON  
✅ ArchivesSpace Staff Interface (8080) - Login page (admin/admin)
✅ ArchivesSpace Public Interface (8081) - Homepage
✅ Solr Admin (8983) - Admin UI accessible
```

## How to Test

```bash
# 1. Setup (creates .env from template)
./verify-setup.sh

# 2. Build (downloads ArchivesSpace v2.6.0 from GitHub releases)
docker compose build

# 3. Start (~60 seconds with included test dump)
docker compose up -d

# 4. Wait for services
sleep 70

# 5. Run tests
./test-environment.sh
```

Expected output from test script:
```
✅ Backend API (8089) - HTTP 200
✅ Staff Interface (8080) - HTTP 200  
✅ Public Interface (8081) - HTTP 200
✅ Solr Admin (8983) - HTTP 200
✅ MySQL (3306)
   Tables: 96
   Schema version: 120
```

## Access URLs

- Staff: http://localhost:8080 (admin/admin)
- Public: http://localhost:8081
- API: http://localhost:8089

## What's Included

- `backup-data/mysql/archivesspace.sql` - 344KB test dump with full schema
- Auto-initialization if dump is removed
- Docker-managed volumes for data persistence
- All services tested and verified working

## Clean Restart

```bash
docker compose down -v
docker compose up -d
# Wait 60 seconds, everything restored from dump
```
