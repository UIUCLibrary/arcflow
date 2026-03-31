#!/bin/bash
# mysql-entrypoint.sh - Restore MySQL database from backup and start MySQL

set -e

echo "🔍 Checking if we need to restore MySQL database from backup..."

# Check if MySQL data directory is empty or doesn't exist
if [ ! -d "/var/lib/mysql/archivesspace" ] || [ ! "$(ls -A /var/lib/mysql/archivesspace 2>/dev/null)" ]; then
    echo "📋 Restoring MySQL database from backup..."
    
    # If backup exists, restore it
    if [ -d "/backup/mysql" ] && [ "$(ls -A /backup/mysql 2>/dev/null)" ]; then
        echo "✅ Backup found, copying to /var/lib/mysql..."
        cp -r /backup/mysql/* /var/lib/mysql/
        chown -R mysql:mysql /var/lib/mysql
        echo "✅ MySQL database restored from backup!"
    else
        echo "⚠️  No backup found - MySQL will initialize with empty database"
    fi
else
    echo "✅ MySQL database already exists"
fi

echo "🚀 Starting MySQL..."

# Execute the original MySQL entrypoint
exec docker-entrypoint.sh mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
