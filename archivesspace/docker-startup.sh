#!/bin/bash

# Startup script for ArchivesSpace in Docker
# Configures database connection and starts ArchivesSpace

set -e

cd /archivesspace

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
        
        export APPCONFIG_DB_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useUnicode=true&characterEncoding=UTF-8&user=${DB_USER}&password=${DB_PASS}"
        echo "Using MySQL database at ${DB_HOST}:${DB_PORT}/${DB_NAME}"
    fi
fi

# Disable embedded Solr (using external Solr)
export APPCONFIG_ENABLE_SOLR=false

# Set Java memory options
export JAVA_OPTS="${ASPACE_JAVA_XMX:--Xmx1g} -XX:+UseG1GC"

echo "Starting ArchivesSpace..."
echo "Java options: $JAVA_OPTS"
echo "Database URL: $APPCONFIG_DB_URL"

# Start ArchivesSpace
exec /archivesspace/archivesspace.sh
