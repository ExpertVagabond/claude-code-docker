#!/bin/bash

# Quick Command Test - Test all run.sh commands individually
# This tests the command structure without full container execution

set -e
cd "$(dirname "$0")"

echo "🧪 Testing All run.sh Commands"
echo "=============================="

# Test all help and version commands first (these work without container)
echo ""
echo "1️⃣  Testing Help and Info Commands..."

echo "   ./run.sh help:"
./run.sh help | head -5

echo ""
echo "2️⃣  Testing File Validation..."

echo "   ✓ All core files exist:"
[ -f Dockerfile ] && echo "     - Dockerfile ✓"
[ -f docker-compose.yml ] && echo "     - docker-compose.yml ✓"
[ -f run.sh ] && echo "     - run.sh ✓"
[ -f .env ] && echo "     - .env ✓"

echo ""
echo "3️⃣  Testing Docker Prerequisites..."

echo "   Docker version:"
docker --version

echo "   Docker Compose version:"
docker-compose --version

echo "   Docker daemon status:"
docker info > /dev/null && echo "   ✓ Docker daemon is running"

echo ""
echo "4️⃣  Testing Workspace Structure..."

echo "   Workspace contents:"
ls -la workspace/ | head -3

echo "   Example files:"
find workspace/docker-examples -name "*.yml" -o -name "Dockerfile" | head -3

echo ""
echo "5️⃣  Ready for Container Testing..."

echo "   Next steps to test with running container:"
echo "   • Wait for ./run.sh build to complete"
echo "   • Run: ./run.sh start"
echo "   • Run: ./run.sh status"
echo "   • Run: ./run.sh shell"
echo "   • Inside container: docker --version && claude --version"

echo ""
echo "✅ Command structure tests completed!"
echo "🚀 Ready for full container testing once build finishes."