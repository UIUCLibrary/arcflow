#!/bin/bash
# solr-entrypoint.sh - Create Solr cores from backups or configsets

set -e

echo "🔍 Checking Solr setup..."

# Function to create core from configset
create_core_from_configset() {
    local core_name=$1
    local configset_path=$2
    
    if [ -d "$configset_path" ]; then
        echo "📋 Creating $core_name from configset..."
        if curl -s "http://localhost:8983/solr/admin/cores?action=CREATE&name=$core_name&instanceDir=$core_name&configSet=$(basename $configset_path)&dataDir=data" | grep -q '"status":0'; then
            echo "✅ $core_name created from configset!"
            return 0
        else
            echo "⚠️  Failed to create $core_name from configset"
            return 1
        fi
    else
        echo "⚠️  No configset found at $configset_path"
        return 1
    fi
}

echo "🚀 Starting Solr..."

# Start Solr in the background
solr-foreground &
SOLR_PID=$!

# Wait for Solr to be ready
echo "⏳ Waiting for Solr to start..."
sleep 10

echo "🔧 Setting up Solr cores..."

# Handle blacklight-core
if [ ! -d "/var/solr/data/blacklight-core/data/index" ] || [ ! "$(ls -A /var/solr/data/blacklight-core/data/index 2>/dev/null)" ]; then
    # Check if backup exists
    if [ -d "/backup/blacklight-core" ] && [ "$(ls -A /backup/blacklight-core 2>/dev/null)" ]; then
        echo "📋 Restoring blacklight-core from backup..."
        mkdir -p /var/solr/data
        cp -r /backup/blacklight-core /var/solr/data/
        echo "✅ blacklight-core restored from backup!"
    else
        # No backup, try creating from configset
        echo "ℹ️  No backup found for blacklight-core, creating blank core from configset..."
        if ! curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=blacklight-core" | grep -q '"instanceDir"'; then
            create_core_from_configset "blacklight-core" "/opt/solr/server/solr/configsets/blacklight-core"
        else
            echo "✅ blacklight-core already exists"
        fi
    fi
else
    echo "✅ blacklight-core already exists"
fi

# Handle archivesspace-solr
if [ ! -d "/var/solr/data/archivesspace-solr/data/index" ] || [ ! "$(ls -A /var/solr/data/archivesspace-solr/data/index 2>/dev/null)" ]; then
    # Check if backup exists
    if [ -d "/backup/archivesspace-solr" ] && [ "$(ls -A /backup/archivesspace-solr 2>/dev/null)" ]; then
        echo "📋 Restoring archivesspace-solr from backup..."
        mkdir -p /var/solr/data
        cp -r /backup/archivesspace-solr /var/solr/data/
        echo "✅ archivesspace-solr restored from backup!"
    else
        # No backup, try creating from configset
        echo "ℹ️  No backup found for archivesspace-solr, creating blank core from configset..."
        if ! curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=archivesspace-solr" | grep -q '"instanceDir"'; then
            create_core_from_configset "archivesspace-solr" "/opt/solr/server/solr/configsets/archivesspace"
        else
            echo "✅ archivesspace-solr already exists"
        fi
    fi
else
    echo "✅ archivesspace-solr already exists"
fi

echo "✅ Solr ready!"

# Wait for Solr process
wait $SOLR_PID
