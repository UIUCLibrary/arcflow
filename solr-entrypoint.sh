#!/bin/bash
# solr-entrypoint.sh - Create Solr cores from backups or configsets

set -e

echo "🔍 Checking Solr setup..."

# Function to check if a backup has actual core data (not just README)
has_valid_backup() {
    local backup_path=$1
    # Check if conf/solrconfig.xml exists in the backup (indicates a valid core backup)
    if [ -f "$backup_path/conf/solrconfig.xml" ]; then
        return 0
    fi
    return 1
}

# Function to create core from configset
create_core_from_configset() {
    local core_name=$1
    local configset_name=$2
    
    # Verify configset has required files
    if [ ! -f "/opt/solr/server/solr/configsets/$configset_name/solrconfig.xml" ]; then
        echo "⚠️  Configset $configset_name missing solrconfig.xml"
        return 1
    fi
    
    # Copy configset to Solr data directory (Solr needs write access for managed schema)
    echo "📋 Copying configset $configset_name to /var/solr/data/configsets/..."
    mkdir -p /var/solr/data/configsets
    cp -r /opt/solr/server/solr/configsets/$configset_name /var/solr/data/configsets/
    
    echo "📋 Creating $core_name from configset $configset_name..."
    local response=$(curl -s "http://localhost:8983/solr/admin/cores?action=CREATE&name=$core_name&instanceDir=$core_name&configSet=$configset_name&dataDir=data")
    
    if echo "$response" | grep -q '"status":0'; then
        echo "✅ $core_name created from configset!"
        return 0
    else
        echo "⚠️  Failed to create $core_name from configset"
        echo "Response: $response"
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
if ! curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=blacklight-core" | grep -q '"instanceDir"'; then
    # Core doesn't exist, check for backup
    if has_valid_backup "/backup/blacklight-core"; then
        echo "📋 Restoring blacklight-core from backup..."
        mkdir -p /var/solr/data
        cp -r /backup/blacklight-core /var/solr/data/
        echo "✅ blacklight-core restored from backup!"
    else
        # No valid backup, create from configset
        echo "ℹ️  No valid backup found for blacklight-core, creating blank core from configset..."
        create_core_from_configset "blacklight-core" "blacklight-core" || echo "⚠️  Could not create blacklight-core"
    fi
else
    echo "✅ blacklight-core already exists"
fi

# Handle archivesspace-solr
if ! curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=archivesspace-solr" | grep -q '"instanceDir"'; then
    # Core doesn't exist, check for backup
    if has_valid_backup "/backup/archivesspace-solr"; then
        echo "📋 Restoring archivesspace-solr from backup..."
        mkdir -p /var/solr/data
        cp -r /backup/archivesspace-solr /var/solr/data/
        echo "✅ archivesspace-solr restored from backup!"
    else
        # No valid backup, create from configset
        echo "ℹ️  No valid backup found for archivesspace-solr, creating blank core from configset..."
        create_core_from_configset "archivesspace-solr" "archivesspace" || echo "⚠️  Could not create archivesspace-solr"
    fi
else
    echo "✅ archivesspace-solr already exists"
fi

echo "✅ Solr ready!"

# Wait for Solr process
wait $SOLR_PID
