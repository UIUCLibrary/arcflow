# Local Solr Quick Reference

Quick reference for common tasks when working with local Solr.

## Setup

```bash
# Automated setup (recommended)
./scripts/setup-local-solr.sh

# Manual setup
docker-compose up -d
```

## Daily Usage

```bash
# Start Solr
docker-compose up -d

# Stop Solr
docker-compose down

# View logs
docker-compose logs -f solr

# Restart Solr
docker-compose restart solr
```

## Accessing Solr

- **Admin UI**: http://localhost:8983/solr/
- **Core URL**: http://localhost:8983/solr/arclight
- **Query endpoint**: http://localhost:8983/solr/arclight/select

## Using with arcflow

```bash
# Run arcflow with local Solr
python arcflow/main.py \
  --arclight-dir /path/to/arcuit \
  --aspace-dir /path/to/archivesspace \
  --solr-url http://localhost:8983/solr/arclight

# Or set environment variable
export ARCLIGHT_SOLR_URL=http://localhost:8983/solr/arclight
```

## Data Management

```bash
# Clear all documents
curl "http://localhost:8983/solr/arclight/update?commit=true" \
  -H "Content-Type: text/xml" \
  --data-binary '<delete><query>*:*</query></delete>'

# Count documents
curl "http://localhost:8983/solr/arclight/select?q=*:*&rows=0" | jq '.response.numFound'

# Complete reset (removes all data)
docker-compose down
docker volume rm arcflow_solr-data
docker-compose up -d
```

## Cloning from Remote

```bash
# 1. SSH tunnel (in separate terminal)
ssh -NTL 8984:localhost:8983 archivesspace-dev.library.illinois.edu

# 2. Export from remote
curl "http://localhost:8984/solr/arclight/select?q=*:*&rows=10000&wt=json" > /tmp/remote-docs.json

# 3. Import to local (see docs/LOCAL_SOLR_SETUP.md for full script)
```

## Troubleshooting

```bash
# Check if Solr is responding
curl http://localhost:8983/solr/admin/cores?action=STATUS

# Check container status
docker-compose ps

# View detailed logs
docker-compose logs --tail=100 solr

# Recreate core manually
docker exec arclight-solr solr create_core -c arclight -d /opt/solr-config

# Access container shell
docker exec -it arclight-solr bash
```

## Full Documentation

See [LOCAL_SOLR_SETUP.md](LOCAL_SOLR_SETUP.md) for complete documentation.
