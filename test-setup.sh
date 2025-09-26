#!/bin/bash

# Test script for Claude Code Docker setup
set -e

echo "🧪 Testing Claude Code Docker Setup"
echo "=================================="

# Change to the project directory
cd "$(dirname "$0")"

# Check if Docker is running
echo "1. Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✅ Docker is running"

# Check if .env file exists and has API key
echo "2. Checking environment configuration..."
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.example .env
    echo "❌ Please edit .env and add your CLAUDE_API_KEY"
    exit 1
fi

if grep -q "your_claude_api_key_here" .env; then
    echo "❌ Please update CLAUDE_API_KEY in .env file"
    exit 1
fi
echo "✅ Environment configuration looks good"

# Build the Docker image
echo "3. Building Docker image..."
if ! ./run.sh build; then
    echo "❌ Failed to build Docker image"
    exit 1
fi
echo "✅ Docker image built successfully"

# Start the container
echo "4. Starting container..."
if ! ./run.sh start; then
    echo "❌ Failed to start container"
    exit 1
fi
echo "✅ Container started successfully"

# Wait for container to be ready
echo "5. Waiting for container to be ready..."
sleep 10

# Test if we can access the container
echo "6. Testing container access..."
if ! docker-compose exec -T claude-code echo "Container accessible" > /dev/null 2>&1; then
    echo "❌ Cannot access container"
    ./run.sh logs
    exit 1
fi
echo "✅ Container is accessible"

# Test Claude Code installation
echo "7. Testing Claude Code installation..."
if ! docker-compose exec -T claude-code claude --version > /dev/null 2>&1; then
    echo "❌ Claude Code not working in container"
    ./run.sh logs
    exit 1
fi
echo "✅ Claude Code is installed and working"

# Test Docker-in-Docker functionality
echo "8. Testing Docker-in-Docker..."
if ! docker-compose exec -T claude-code docker --version > /dev/null 2>&1; then
    echo "❌ Docker not available in container"
    exit 1
fi
echo "✅ Docker is available in container"

# Test building an image inside the container
echo "9. Testing Docker build inside container..."
docker-compose exec -T claude-code sh -c "cd /workspace && docker build -f test-dockerfile -t test-app ." > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Failed to build test image inside container"
    exit 1
fi
echo "✅ Successfully built Docker image inside container"

# List images to verify
echo "10. Verifying built image..."
if ! docker-compose exec -T claude-code docker images test-app | grep -q test-app; then
    echo "❌ Test image not found"
    exit 1
fi
echo "✅ Test image verified"

# Clean up test image
echo "11. Cleaning up test resources..."
docker-compose exec -T claude-code docker rmi test-app > /dev/null 2>&1

echo ""
echo "🎉 All tests passed! Claude Code Docker setup is working correctly."
echo ""
echo "Next steps:"
echo "  • Access the container: ./run.sh shell"
echo "  • Run Claude Code: claude 'your prompt here'"
echo "  • Build Docker images: docker build -t myapp ."
echo "  • Stop the container: ./run.sh stop"
echo ""