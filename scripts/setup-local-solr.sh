#!/bin/bash
# Helper script to set up local ArcLight Solr for testing
# This script automates the process of getting Solr config and starting the local instance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCFLOW_DIR="$(dirname "$SCRIPT_DIR")"
SOLR_CONFIG_DIR="${ARCFLOW_DIR}/solr-config"

echo "=== ArcLight Solr Local Setup Helper ==="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
if ! command_exists docker; then
    echo "ERROR: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command_exists docker-compose; then
    echo "ERROR: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"
echo ""

# Check if solr-config already exists
if [ -d "$SOLR_CONFIG_DIR" ]; then
    echo "✓ Solr configuration directory already exists at: $SOLR_CONFIG_DIR"
    echo ""
else
    echo "Solr configuration directory not found. Choose an option to get it:"
    echo ""
    echo "1) Copy from local Arcuit installation (requires Arcuit to be installed)"
    echo "2) Clone from ArcLight GitHub repository"
    echo "3) Download from remote Solr via SSH tunnel (requires access to archivesspace-dev)"
    echo "4) Skip (I'll configure it manually later)"
    echo ""
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            read -p "Enter path to your Arcuit directory: " arcuit_path
            if [ ! -d "$arcuit_path" ]; then
                echo "ERROR: Directory not found: $arcuit_path"
                exit 1
            fi
            
            cd "$arcuit_path"
            if ! command_exists bundle; then
                echo "ERROR: bundle command not found. Make sure Ruby bundler is installed."
                exit 1
            fi
            
            ARCLIGHT_PATH=$(bundle show arclight 2>/dev/null || echo "")
            if [ -z "$ARCLIGHT_PATH" ]; then
                echo "ERROR: Could not find arclight gem. Is it installed in this project?"
                exit 1
            fi
            
            echo "Copying Solr config from: ${ARCLIGHT_PATH}/solr/config"
            cp -r "${ARCLIGHT_PATH}/solr/config" "$SOLR_CONFIG_DIR"
            echo "✓ Solr configuration copied successfully"
            ;;
            
        2)
            echo "Cloning ArcLight repository..."
            TMP_DIR=$(mktemp -d)
            cd "$TMP_DIR"
            git clone --depth 1 https://github.com/projectblacklight/arclight.git
            
            if [ ! -d "arclight/solr/config" ]; then
                echo "ERROR: Could not find solr/config in cloned repository"
                rm -rf "$TMP_DIR"
                exit 1
            fi
            
            echo "Copying Solr config..."
            cp -r arclight/solr/config "$SOLR_CONFIG_DIR"
            
            echo "Cleaning up..."
            rm -rf "$TMP_DIR"
            echo "✓ Solr configuration downloaded successfully"
            ;;
            
        3)
            echo ""
            echo "This option requires an SSH tunnel to be running."
            echo "In another terminal, run:"
            echo "  ssh -NTL 8984:localhost:8983 archivesspace-dev.library.illinois.edu"
            echo ""
            read -p "Press Enter when the SSH tunnel is ready..."
            
            # Test connection
            if ! curl -s "http://localhost:8984/solr/admin/cores?action=STATUS" > /dev/null; then
                echo "ERROR: Cannot connect to Solr via SSH tunnel. Make sure the tunnel is running."
                exit 1
            fi
            
            echo "Downloading Solr configuration..."
            mkdir -p "${SOLR_CONFIG_DIR}/conf"
            
            curl -s "http://localhost:8984/solr/arclight/admin/file?file=managed-schema" > "${SOLR_CONFIG_DIR}/conf/managed-schema"
            curl -s "http://localhost:8984/solr/arclight/admin/file?file=solrconfig.xml" > "${SOLR_CONFIG_DIR}/conf/solrconfig.xml"
            
            echo "✓ Solr configuration downloaded successfully"
            ;;
            
        4)
            echo "Skipping configuration download. You'll need to set up solr-config manually."
            mkdir -p "$SOLR_CONFIG_DIR"
            ;;
            
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
    echo ""
fi

# Update .gitignore to exclude solr-config if not already there
if ! grep -q "solr-config" "${ARCFLOW_DIR}/.gitignore" 2>/dev/null; then
    echo "Adding solr-config to .gitignore..."
    echo "" >> "${ARCFLOW_DIR}/.gitignore"
    echo "# Local Solr configuration (can vary by environment)" >> "${ARCFLOW_DIR}/.gitignore"
    echo "solr-config/" >> "${ARCFLOW_DIR}/.gitignore"
fi

# Start Docker Compose
echo "Starting local Solr instance..."
cd "$ARCFLOW_DIR"

if docker-compose ps | grep -q "arclight-solr"; then
    echo "Solr container is already running."
    read -p "Do you want to restart it? (y/n): " restart
    if [ "$restart" = "y" ] || [ "$restart" = "Y" ]; then
        docker-compose restart solr
        echo "✓ Solr restarted"
    fi
else
    docker-compose up -d
    echo "✓ Solr container started"
fi

# Wait for Solr to be ready
echo ""
echo "Waiting for Solr to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" > /dev/null 2>&1; then
        echo "✓ Solr is ready!"
        break
    fi
    attempt=$((attempt + 1))
    sleep 1
    echo -n "."
done

if [ $attempt -eq $max_attempts ]; then
    echo ""
    echo "WARNING: Solr did not become ready within expected time. Check logs with:"
    echo "  docker-compose logs solr"
    exit 1
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Solr Admin UI: http://localhost:8983/solr/"
echo ""
echo "To use with arcflow:"
echo "  python arcflow/main.py --solr-url http://localhost:8983/solr/arclight ..."
echo ""
echo "To view logs:"
echo "  docker-compose logs -f solr"
echo ""
echo "To stop Solr:"
echo "  docker-compose down"
echo ""
echo "To clone data from remote Solr, see: docs/LOCAL_SOLR_SETUP.md"
echo ""
