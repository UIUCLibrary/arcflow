#!/bin/bash
# test-environment.sh - Test that the local ArchivesSpace environment is working

set -e

echo "🧪 Testing Local ArchivesSpace Environment"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if services are running
if ! docker compose ps | grep -q "local-archivesspace-mysql.*healthy"; then
    echo -e "${RED}❌ Services are not running${NC}"
    echo "Start with: docker compose up -d"
    exit 1
fi

echo "⏳ Waiting for ArchivesSpace to be fully ready..."
echo "   (This takes ~60 seconds if services just started, or ~3 minutes on first run)"
echo ""

# Wait for services with retries
max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8089/ | grep -q "200"; then
        break
    fi
    attempt=$((attempt + 1))
    sleep 3
    if [ $((attempt % 10)) -eq 0 ]; then
        echo "   Still waiting... ($attempt/${max_attempts})"
    fi
done

echo ""
echo "📊 Testing All Services:"
echo "========================"
echo ""

# Test Backend API
backend_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8089/)
if [ "$backend_status" = "200" ]; then
    version=$(curl -s http://localhost:8089/ | grep -o '"archivesSpaceVersion":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✅ Backend API (8089)${NC} - HTTP $backend_status"
    echo "   Version: $version"
else
    echo -e "${RED}❌ Backend API (8089)${NC} - HTTP $backend_status"
fi

# Test Staff Interface
staff_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
if [ "$staff_status" = "200" ]; then
    echo -e "${GREEN}✅ Staff Interface (8080)${NC} - HTTP $staff_status"
    echo "   Login at: http://localhost:8080 (admin/admin)"
else
    echo -e "${RED}❌ Staff Interface (8080)${NC} - HTTP $staff_status"
fi

# Test Public Interface
public_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/)
if [ "$public_status" = "200" ]; then
    echo -e "${GREEN}✅ Public Interface (8081)${NC} - HTTP $public_status"
else
    echo -e "${RED}❌ Public Interface (8081)${NC} - HTTP $public_status"
fi

# Test Solr
solr_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8983/solr/)
if [ "$solr_status" = "200" ]; then
    echo -e "${GREEN}✅ Solr Admin (8983)${NC} - HTTP $solr_status"
    
    # Check for cores
    cores=$(curl -s http://localhost:8983/solr/admin/cores?action=STATUS | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | tr '\n' ',' || echo "none")
    if [ "$cores" != "none" ] && [ -n "$cores" ]; then
        echo "   Cores: ${cores%,}"
    else
        echo -e "   ${YELLOW}⚠ No cores configured${NC} (add configsets/ to enable)"
    fi
else
    echo -e "${RED}❌ Solr Admin (8983)${NC} - HTTP $solr_status"
fi

# Test MySQL
echo -e "${GREEN}✅ MySQL (3306)${NC}"
table_count=$(docker exec local-archivesspace-mysql mysql -u root -proot123 -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='archivesspace';" 2>&1 | grep -v Warning | tail -1)
schema_version=$(docker exec local-archivesspace-mysql mysql -u root -proot123 archivesspace -e "SELECT version FROM schema_info ORDER BY version DESC LIMIT 1;" 2>&1 | grep -v Warning | tail -1)
echo "   Tables: $table_count"
echo "   Schema version: $schema_version"

echo ""
echo "=========================================="
if [ "$backend_status" = "200" ] && [ "$staff_status" = "200" ] && [ "$public_status" = "200" ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "Access ArchivesSpace at:"
    echo "  • Staff: http://localhost:8080 (admin/admin)"
    echo "  • Public: http://localhost:8081"
    echo "  • API: http://localhost:8089"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    echo "Check logs with: docker compose logs"
    exit 1
fi
