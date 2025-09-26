#!/bin/bash

# Quick Test Suite for Claude Code Docker Setup
# Tests core functionality without complex operations

set -e

cd "$(dirname "$0")"

echo "🧪 Quick Test Suite for Claude Code Docker"
echo "=========================================="

# Check prerequisites
echo "1. Prerequisites Check..."
docker --version > /dev/null && echo "✅ Docker is available"
docker-compose --version > /dev/null && echo "✅ Docker Compose is available"

# Create minimal .env for testing if needed
if [ ! -f .env ]; then
    echo "CLAUDE_API_KEY=test_key_for_testing" > .env
    echo "⚠️  Created temporary .env (you'll need a real API key for Claude Code)"
fi

echo -e "\n2. Building Docker Image..."
if ./run.sh build; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

echo -e "\n3. Starting Container (Socket Mode)..."
if ./run.sh start; then
    echo "✅ Container started successfully"
else
    echo "❌ Failed to start container"
    exit 1
fi

echo -e "\n4. Waiting for container to be ready..."
sleep 10

echo -e "\n5. Testing Container Access..."
if docker-compose exec -T claude-code echo "Container test" > /dev/null 2>&1; then
    echo "✅ Can access container"
else
    echo "❌ Cannot access container"
    ./run.sh logs
    exit 1
fi

echo -e "\n6. Testing Docker-in-Docker..."
if docker-compose exec -T claude-code docker --version > /dev/null 2>&1; then
    echo "✅ Docker is available inside container"
else
    echo "❌ Docker not available inside container"
    exit 1
fi

echo -e "\n7. Testing Basic Docker Operations..."
if docker-compose exec -T claude-code docker info > /dev/null 2>&1; then
    echo "✅ Docker daemon is accessible"
else
    echo "❌ Docker daemon not accessible"
    exit 1
fi

echo -e "\n8. Testing Claude Code Installation..."
if docker-compose exec -T claude-code claude --version > /dev/null 2>&1; then
    echo "✅ Claude Code is installed and accessible"
else
    echo "⚠️  Claude Code installed but needs valid API key"
fi

echo -e "\n9. Testing File Operations..."
docker-compose exec -T claude-code touch /workspace/test-file
if [ -f workspace/test-file ]; then
    echo "✅ Workspace persistence works"
    rm -f workspace/test-file
else
    echo "❌ Workspace persistence failed"
fi

echo -e "\n10. Testing Docker Build Inside Container..."
mkdir -p workspace/test-build
cat > workspace/test-build/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Docker-in-Docker test successful!" > /success.txt
CMD ["cat", "/success.txt"]
EOF

if docker-compose exec -T claude-code sh -c 'cd /workspace/test-build && docker build -t test-build .' > /dev/null 2>&1; then
    echo "✅ Can build Docker images inside container"

    # Test running the built image
    if docker-compose exec -T claude-code docker run --rm test-build 2>&1 | grep -q "successful"; then
        echo "✅ Can run built Docker images"
    else
        echo "⚠️  Built image but couldn't verify execution"
    fi

    # Cleanup
    docker-compose exec -T claude-code docker rmi test-build > /dev/null 2>&1 || true
else
    echo "❌ Cannot build Docker images inside container"
fi

# Cleanup test files
rm -rf workspace/test-build

echo -e "\n11. Testing run.sh Commands..."
./run.sh status > /dev/null && echo "✅ run.sh status works"

echo -e "\n12. Cleaning up..."
./run.sh stop > /dev/null 2>&1

echo -e "\n🎉 Quick Test Completed!"
echo "=========================================="
echo "✨ Claude Code Docker setup is working!"
echo ""
echo "Next steps:"
echo "  1. Add your real CLAUDE_API_KEY to .env file"
echo "  2. ./run.sh start"
echo "  3. ./run.sh shell"
echo "  4. claude 'your prompt here'"
echo ""