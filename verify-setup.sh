#!/bin/bash
# verify-setup.sh - Verify local testing environment is properly configured

set -e

echo "🔍 Verifying Local Testing Environment Setup..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

# Check for required files
echo "📁 Checking required files..."
required_files=(
    "docker-compose.yml"
    "mysql-entrypoint.sh"
    "solr-entrypoint.sh"
    "LOCAL_TESTING_README.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} Found: $file"
    else
        echo -e "${RED}✗${NC} Missing: $file"
        ((errors++))
    fi
done
echo ""

# Check for backup data directories
echo "📦 Checking backup-data structure..."
backup_dirs=(
    "backup-data/mysql"
    "backup-data/archivesspace"
    "backup-data/blacklight-core"
    "backup-data/archivesspace-solr"
)

for dir in "${backup_dirs[@]}"; do
    if [ -d "$dir" ]; then
        # Check if directory has content
        if [ "$(ls -A "$dir" 2>/dev/null)" ]; then
            echo -e "${GREEN}✓${NC} Found with data: $dir"
        else
            echo -e "${YELLOW}⚠${NC}  Found but empty: $dir (will need data from dev server)"
            ((warnings++))
        fi
    else
        echo -e "${YELLOW}⚠${NC}  Missing: $dir (will be created automatically)"
        ((warnings++))
    fi
done
echo ""

# Check for configsets
echo "⚙️  Checking Solr configsets..."
configset_dirs=(
    "configsets/blacklight-core"
    "configsets/archivesspace"
)

for dir in "${configset_dirs[@]}"; do
    if [ -d "$dir" ]; then
        # Check for required config files
        if [ -f "$dir/conf/solrconfig.xml" ] || [ -f "$dir/solrconfig.xml" ]; then
            echo -e "${GREEN}✓${NC} Found with config: $dir"
        else
            echo -e "${YELLOW}⚠${NC}  Found but missing solrconfig.xml: $dir"
            ((warnings++))
        fi
    else
        echo -e "${RED}✗${NC} Missing: $dir"
        ((errors++))
    fi
done
echo ""

# Check Docker
echo "🐳 Checking Docker..."
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    
    # Check if Docker is running
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker is running"
    else
        echo -e "${RED}✗${NC} Docker is not running (start Docker Desktop or Rancher Desktop)"
        ((errors++))
    fi
    
    # Check Docker Compose
    if docker compose version &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker Compose is available"
    elif command -v docker-compose &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker Compose (v1) is available"
        echo -e "${YELLOW}⚠${NC}  Consider upgrading to Docker Compose v2 (docker compose)"
        ((warnings++))
    else
        echo -e "${RED}✗${NC} Docker Compose not found"
        ((errors++))
    fi
else
    echo -e "${RED}✗${NC} Docker is not installed"
    ((errors++))
fi
echo ""

# Check line endings on shell scripts
echo "📝 Checking shell script line endings..."
if command -v file &> /dev/null; then
    for script in mysql-entrypoint.sh solr-entrypoint.sh; do
        if [ -f "$script" ]; then
            line_ending=$(file "$script" | grep -o "CRLF\|LF" || echo "LF")
            if [[ "$line_ending" == "LF" ]] || ! echo "$line_ending" | grep -q "CRLF"; then
                echo -e "${GREEN}✓${NC} $script has correct line endings"
            else
                echo -e "${RED}✗${NC} $script has CRLF line endings (should be LF)"
                echo "   Fix with: dos2unix $script or change in your editor"
                ((errors++))
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠${NC}  Cannot check line endings (file command not available)"
    ((warnings++))
fi
echo ""

# Check if services are running
echo "🚀 Checking running services..."
if docker compose ps 2>/dev/null | grep -q "local-archivesspace-mysql"; then
    echo -e "${GREEN}✓${NC} Services appear to be running"
    echo "   Run 'docker compose ps' for details"
else
    echo -e "${YELLOW}ℹ${NC}  Services are not running (this is fine for initial setup)"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✓ Setup verification complete - no issues found!${NC}"
    echo ""
    echo "You're ready to run: docker compose up -d"
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup verification complete with $warnings warning(s)${NC}"
    echo ""
    echo "You can proceed, but you may need to:"
    echo "  1. Get backup data from dev server (see LOCAL_TESTING_README.md)"
    echo "  2. Get Solr configsets (see configsets/README.md)"
else
    echo -e "${RED}✗ Setup verification found $errors error(s) and $warnings warning(s)${NC}"
    echo ""
    echo "Please fix the errors before proceeding."
    exit 1
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
