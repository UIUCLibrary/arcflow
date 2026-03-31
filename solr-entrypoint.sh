#!/bin/bash
# solr-entrypoint.sh - Restore from backup and start Solr

set -e

echo "🔍 Checking if we need to restore from backups..."

# Restore blacklight-core if needed
if [ ! -d "/var/solr/data/blacklight-core/data/index" ] || [ ! "$(ls -A /var/solr/data/blacklight-core/data/index 2>/dev/null)" ]; then
    echo "📋 Restoring blacklight-core from backup..."
    mkdir -p /var/solr/data
    if [ -d "/backup/blacklight-core" ]; then
        cp -r /backup/blacklight-core /var/solr/data/
        echo "✅ blacklight-core restored!"
    else
        echo "⚠️  No backup found for blacklight-core"
    fi
else
    echo "✅ blacklight-core already exists"
fi

# Restore archivesspace Solr core if needed
if [ ! -d "/var/solr/data/archivesspace-solr/data/index" ] || [ ! "$(ls -A /var/solr/data/archivesspace-solr/data/index 2>/dev/null)" ]; then
    echo "📋 Restoring archivesspace-solr from backup..."
    mkdir -p /var/solr/data
    if [ -d "/backup/archivesspace-solr" ]; then
        cp -r /backup/archivesspace-solr /var/solr/data/
        echo "✅ archivesspace-solr restored!"
    else
        echo "⚠️  No backup found for archivesspace-solr"
    fi
else
    echo "✅ archivesspace-solr already exists"
fi

echo "🚀 Starting Solr..."

# Start Solr in the background
solr-foreground &
SOLR_PID=$!

# Wait for Solr to be ready
echo "⏳ Waiting for Solr to start..."
sleep 10

# Create cores if they don't exist
echo "🔧 Ensuring cores are created..."

# Check and create blacklight-core
if ! curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=blacklight-core" | grep -q '"instanceDir"'; then
    echo "Creating blacklight-core..."
    curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=blacklight-core&instanceDir=blacklight-core&config=solrconfig.xml&dataDir=data"
fi

# Check and create archivesspace-solr
if ! curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=archivesspace-solr" | grep -q '"instanceDir"'; then
    echo "Creating archivesspace-solr..."
    curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=archivesspace-solr&instanceDir=archivesspace-solr&config=solrconfig.xml&dataDir=data"
fi

echo "✅ Both cores ready!"

# Wait for Solr process
wait $SOLR_PID
