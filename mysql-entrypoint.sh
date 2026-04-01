#!/bin/bash
# mysql-entrypoint.sh - Import MySQL database from SQL dump and start MySQL

set -e

echo "🔍 Checking if we need to import MySQL database from backup..."

# Check if MySQL data directory is empty or doesn't exist
if [ ! -d "/var/lib/mysql/archivesspace" ] || [ ! "$(ls -A /var/lib/mysql/archivesspace 2>/dev/null)" ]; then
    echo "📋 Database not initialized yet..."
    
    # Check if SQL dump file exists
    if [ -f "/backup/mysql/archivesspace.sql" ]; then
        echo "✅ SQL dump found at /backup/mysql/archivesspace.sql"
        echo "📥 Will import database after MySQL starts..."
        
        # Create a flag file to trigger import after MySQL is ready
        touch /tmp/need_import
    else
        echo "⚠️  No SQL dump found - MySQL will initialize with empty database"
    fi
else
    echo "✅ MySQL database already exists"
fi

echo "🚀 Starting MySQL..."

# Start MySQL in the background
docker-entrypoint.sh mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci &
MYSQL_PID=$!

# If we need to import, wait for MySQL to be ready and then import
if [ -f /tmp/need_import ]; then
    echo "⏳ Waiting for MySQL to be ready..."
    
    # Wait for MySQL to be ready
    for i in {1..30}; do
        if mysqladmin ping -h localhost -u root -proot123 --silent 2>/dev/null; then
            echo "✅ MySQL is ready!"
            break
        fi
        echo "Waiting for MySQL... ($i/30)"
        sleep 2
    done
    
    # Create database if it doesn't exist
    echo "📋 Creating archivesspace database..."
    mysql -u root -proot123 -e "CREATE DATABASE IF NOT EXISTS archivesspace CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
    
    # Create user and grant privileges
    echo "📋 Creating database user..."
    mysql -u root -proot123 -e "CREATE USER IF NOT EXISTS 'as'@'%' IDENTIFIED BY 'as123';" 2>/dev/null || true
    mysql -u root -proot123 -e "GRANT ALL PRIVILEGES ON archivesspace.* TO 'as'@'%';" 2>/dev/null || true
    mysql -u root -proot123 -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    
    # Import the SQL dump
    echo "📥 Importing database from /backup/mysql/archivesspace.sql..."
    mysql -u root -proot123 archivesspace < /backup/mysql/archivesspace.sql
    
    echo "✅ Database import complete!"
    rm /tmp/need_import
fi

# Wait for MySQL process
wait $MYSQL_PID
