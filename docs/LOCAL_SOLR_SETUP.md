# Local ArcLight Solr Setup for Testing

This guide walks you through setting up a local Docker-based ArcLight Solr instance for testing indexing without affecting the shared development environment.

## Prerequisites

- Docker and Docker Compose installed on your local machine
- SSH access to the remote archivesspace-dev.library.illinois.edu server
- `jq` command-line tool (for JSON processing) - install with `brew install jq` on macOS or `apt-get install jq` on Linux

## Overview

This setup allows you to:
1. Run ArcLight Solr locally in a Docker container
2. Clone/copy the existing Solr core from the remote dev environment
3. Test indexing locally without affecting the shared dev instance
4. Easily rebuild and reset when needed

## Quick Start

### 1. Get the ArcLight Solr Configuration

First, you need to get the Solr configuration from the ArcLight project. The easiest way is to extract it from an existing ArcLight installation or get it from the ArcLight gem.

**Option A: From an existing ArcLight installation (e.g., Arcuit)**

If you have Arcuit or another ArcLight application running locally:

```bash
# Navigate to your Arcuit directory
cd /path/to/arcuit

# Find the ArcLight gem location
ARCLIGHT_PATH=$(bundle show arclight)

# Copy the Solr configuration to arcflow
cp -r "${ARCLIGHT_PATH}/solr/config" /path/to/arcflow/solr-config
```

**Option B: From the ArcLight GitHub repository**

```bash
# Clone ArcLight repository temporarily
cd /tmp
git clone https://github.com/projectblacklight/arclight.git
cd arclight

# Copy the Solr config to your arcflow directory
cp -r solr/config /path/to/arcflow/solr-config

# Clean up
cd ..
rm -rf arclight
```

**Option C: Download configuration directly from remote Solr**

If you have access to the remote Solr instance via SSH tunnel:

```bash
# Set up SSH tunnel (in a separate terminal)
ssh -NTL 8984:localhost:8983 archivesspace-dev.library.illinois.edu

# Download the configuration
mkdir -p solr-config/conf
cd solr-config/conf

# Download schema
curl "http://localhost:8984/solr/arclight/admin/file?file=managed-schema" > managed-schema

# Download solrconfig
curl "http://localhost:8984/solr/arclight/admin/file?file=solrconfig.xml" > solrconfig.xml

cd ../..
```

### 2. Start the Local Solr Instance

From the arcflow directory:

```bash
docker-compose up -d
```

This will:
- Pull the Solr 8.11.2 Docker image (compatible with ArcLight)
- Create and start a Solr container
- Create an `arclight` core with the provided configuration
- Expose Solr on `http://localhost:8983`

Verify Solr is running:

```bash
curl http://localhost:8983/solr/admin/cores?action=STATUS
```

### 3. Clone Data from Remote Solr (Optional)

If you want to copy the existing data from the remote dev Solr instance:

**Step 1: Set up SSH tunnel to remote Solr**

```bash
# In a separate terminal, create the SSH tunnel
ssh -NTL 8984:localhost:8983 archivesspace-dev.library.illinois.edu
```

Note: We're using port 8984 locally to avoid conflicts with our local Solr on 8983.

**Step 2: Export data from remote Solr**

```bash
# Create a temporary directory for the export
mkdir -p /tmp/solr-export

# Export all documents from the remote Solr arclight core
curl "http://localhost:8984/solr/arclight/select?q=*:*&rows=10000&wt=json" > /tmp/solr-export/remote-docs.json

# Optional: Check how many documents were exported
cat /tmp/solr-export/remote-docs.json | jq '.response.numFound'
```

**Step 3: Import data into local Solr**

```bash
# Extract and reformat the documents for import
cat /tmp/solr-export/remote-docs.json | \
  jq '.response.docs' | \
  jq -c '.[] | {add: {doc: .}}' > /tmp/solr-export/import-docs.jsonl

# Import into local Solr
while IFS= read -r line; do
  echo "$line" | curl -X POST -H 'Content-Type: application/json' \
    'http://localhost:8983/solr/arclight/update?commit=true' -d @-
done < /tmp/solr-export/import-docs.jsonl

# Verify the import
curl "http://localhost:8983/solr/arclight/select?q=*:*&rows=0" | jq '.response.numFound'
```

**Alternative: Using Solr's backup/restore feature**

If you have filesystem access to the remote Solr instance, you can use Solr's built-in backup and restore:

```bash
# On the remote server (via SSH)
# Create a backup
curl "http://localhost:8983/solr/arclight/replication?command=backup&location=/tmp/solr-backup&name=arclight-backup"

# Download the backup to your local machine
scp -r archivesspace-dev.library.illinois.edu:/tmp/solr-backup /tmp/solr-backup

# Restore to local Solr
# First, stop the local Solr container
docker-compose down

# Copy backup to Solr volume
docker run --rm -v arcflow_solr-data:/data -v /tmp/solr-backup:/backup \
  alpine cp -r /backup/snapshot.arclight-backup /data/data/arclight/data/

# Restart Solr
docker-compose up -d
```

### 4. Configure arcflow to Use Local Solr

When running arcflow, use the local Solr URL:

```bash
python arcflow/main.py \
  --arclight-dir /path/to/arcuit \
  --aspace-dir /path/to/archivesspace \
  --solr-url http://localhost:8983/solr/arclight \
  --traject-extra-config /path/to/extra_config.rb
```

Or set it as an environment variable:

```bash
export ARCLIGHT_SOLR_URL=http://localhost:8983/solr/arclight
```

## Managing Your Local Solr Instance

### View Solr Admin UI

Open your browser to: http://localhost:8983/solr/

### View Logs

```bash
docker-compose logs -f solr
```

### Clear All Data and Start Fresh

```bash
# Delete all documents
curl "http://localhost:8983/solr/arclight/update?commit=true" \
  -H "Content-Type: text/xml" \
  --data-binary '<delete><query>*:*</query></delete>'
```

### Completely Reset (Remove Container and Data)

```bash
# Stop and remove containers
docker-compose down

# Remove the volume to delete all data
docker volume rm arcflow_solr-data

# Start fresh
docker-compose up -d
```

### Stop the Local Solr

```bash
docker-compose down
```

## Troubleshooting

### Port 8983 Already in Use

If you're still running the SSH tunnel to the remote Solr on port 8983:

1. Stop the SSH tunnel (Ctrl+C in the terminal running it)
2. Or change the local Solr port in docker-compose.yml:
   ```yaml
   ports:
     - "8985:8983"  # Use port 8985 locally instead
   ```

### Solr Core Not Found

If the arclight core wasn't created properly:

```bash
# Create it manually
docker exec arclight-solr solr create_core -c arclight -d /opt/solr-config
```

### Configuration Issues

If you need to update the Solr configuration:

1. Update files in `solr-config/`
2. Restart Solr:
   ```bash
   docker-compose restart solr
   ```

Or reload the core:

```bash
curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=arclight"
```

## Testing Workflow

Recommended workflow for testing indexing:

1. Start local Solr: `docker-compose up -d`
2. Configure arcflow to use local Solr
3. Run your indexing tests
4. Check results in Solr admin UI: http://localhost:8983/solr/
5. If something breaks, clear data and try again
6. When done, stop Solr: `docker-compose down`

## Integration with Existing Development Setup

You can run this alongside your existing development setup:

- **Local Solr** (Docker): http://localhost:8983 - For arcflow testing
- **Remote Solr** (via SSH tunnel): Use a different port like 8984
- **Local ArchivesSpace**: Keep using remote via asnake config
- **Local Arcuit**: Can point to either Solr instance by changing its config

## Next Steps

Once you've verified the indexing works locally:

1. Document any configuration changes needed
2. Update GitHub Actions workflows to use similar Docker setup
3. Consider adding automated tests that use this Docker setup
