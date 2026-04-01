#!/bin/bash

# Startup script for ArchivesSpace in Docker
# Configures database connection and starts ArchivesSpace

set -e

cd /archivesspace

# Create data directory structure if it doesn't exist (with proper permissions)
mkdir -p /archivesspace/data/tmp 2>/dev/null || true

# Configure database connection if environment variables are set
if [ -n "$ARCHIVESSPACE_DB_TYPE" ]; then
    echo "Configuring database connection..."
    
    # Build database URL based on type
    if [ "$ARCHIVESSPACE_DB_TYPE" = "mysql" ]; then
        DB_HOST=${ARCHIVESSPACE_DB_HOST:-localhost}
        DB_PORT=${ARCHIVESSPACE_DB_PORT:-3306}
        DB_NAME=${ARCHIVESSPACE_DB_NAME:-archivesspace}
        DB_USER=${ARCHIVESSPACE_DB_USER:-as}
        DB_PASS=${ARCHIVESSPACE_DB_PASS:-as123}
        
        # Wait for MySQL to be ready
        echo "Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."
        for i in {1..30}; do
            if nc -z ${DB_HOST} ${DB_PORT} 2>/dev/null; then
                echo "✅ MySQL is ready!"
                sleep 2  # Give it a bit more time to fully initialize
                break
            fi
            echo "Waiting for MySQL... ($i/30)"
            sleep 2
        done
        
        export APPCONFIG_DB_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useUnicode=true&characterEncoding=UTF-8&user=${DB_USER}&password=${DB_PASS}&useSSL=false"
        echo "Using MySQL database at ${DB_HOST}:${DB_PORT}/${DB_NAME}"
        
        # Check if database needs initialization by looking for schema_info table
        echo "Checking if database schema exists..."
        TABLE_COUNT=$(mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} -e "USE ${DB_NAME}; SELECT COUNT(*) as cnt FROM information_schema.tables WHERE table_schema = '${DB_NAME}' AND table_name = 'schema_info';" 2>/dev/null | grep -v cnt | tail -1 || echo "0")
        
        if [ "$TABLE_COUNT" = "0" ]; then
            echo "📋 Database schema not found - initializing ArchivesSpace database..."
            echo "This will take a few minutes on first startup..."
            /archivesspace/scripts/setup-database.sh
            echo "✅ Database initialization complete!"
        else
            echo "✅ Database schema already exists"
        fi
    fi
fi

# Disable embedded Solr (using external Solr)
export APPCONFIG_ENABLE_SOLR=false

# Set Java memory options
export JAVA_OPTS="${ASPACE_JAVA_XMX:--Xmx1g}"

echo "Starting ArchivesSpace..."
echo "Java options: $JAVA_OPTS"
echo "Database URL: $APPCONFIG_DB_URL"

# Start ArchivesSpace
exec /archivesspace/archivesspace.sh
