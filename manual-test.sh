#!/bin/bash

# Manual Test Guide for Claude Code Docker Setup
# Run each command individually to test specific functionality

set -e
cd "$(dirname "$0")"

echo "🧪 Manual Testing Guide for Claude Code Docker"
echo "=============================================="
echo ""
echo "Follow these steps to test your setup manually:"
echo ""

echo "1️⃣  Prerequisites Check"
echo "   Run: docker --version"
echo "   Run: docker-compose --version"
echo "   Expected: Version numbers displayed"
echo ""

echo "2️⃣  Environment Setup"
echo "   Run: cp .env.example .env"
echo "   Edit: Add your CLAUDE_API_KEY to .env file"
echo "   Note: You need a real API key for Claude Code to work"
echo ""

echo "3️⃣  Build Docker Image"
echo "   Run: ./run.sh build"
echo "   Expected: Docker image builds successfully (may take 5-10 minutes)"
echo "   Note: Downloads ~500MB of dependencies first time"
echo ""

echo "4️⃣  Start Container (Socket Mode)"
echo "   Run: ./run.sh start"
echo "   Expected: Container starts and shows 'Container started successfully'"
echo ""

echo "5️⃣  Check Container Status"
echo "   Run: ./run.sh status"
echo "   Expected: Shows container as 'Up'"
echo ""

echo "6️⃣  Access Container Shell"
echo "   Run: ./run.sh shell"
echo "   Expected: Drops you into container bash shell as 'claude' user"
echo "   Inside container, try:"
echo "     - whoami    (should show 'claude')"
echo "     - pwd       (should show '/home/claude')"
echo "     - ls /workspace  (should show workspace directory)"
echo ""

echo "7️⃣  Test Claude Code (Inside Container)"
echo "   Run: claude --version"
echo "   Expected: Shows Claude Code version"
echo "   Run: claude --help"
echo "   Expected: Shows Claude Code help"
echo ""

echo "8️⃣  Test Docker-in-Docker (Inside Container)"
echo "   Run: docker --version"
echo "   Expected: Shows Docker version"
echo "   Run: docker info"
echo "   Expected: Shows Docker daemon info"
echo "   Run: docker images"
echo "   Expected: Lists available Docker images"
echo ""

echo "9️⃣  Test Building Docker Image (Inside Container)"
echo "   Run: cd /workspace"
echo "   Create simple Dockerfile:"
echo "   echo 'FROM alpine:latest' > Dockerfile"
echo "   echo 'RUN echo \"Hello Docker!\" > /hello.txt' >> Dockerfile"
echo "   echo 'CMD [\"cat\", \"/hello.txt\"]' >> Dockerfile"
echo ""
echo "   Run: docker build -t test-app ."
echo "   Expected: Image builds successfully"
echo "   Run: docker run --rm test-app"
echo "   Expected: Prints 'Hello Docker!'"
echo ""

echo "🔟  Exit Container and Test Management"
echo "   Run: exit  (to leave container shell)"
echo "   Run: ./run.sh logs"
echo "   Expected: Shows container logs"
echo "   Run: ./run.sh stop"
echo "   Expected: Stops container"
echo ""

echo "1️⃣1️⃣  Test Docker-in-Docker Mode"
echo "   Run: ./run.sh start-dind"
echo "   Expected: Starts container with full Docker daemon"
echo "   Run: ./run.sh shell-dind"
echo "   Expected: Access DinD container"
echo "   Test same Docker commands as above"
echo ""

echo "1️⃣2️⃣  Test Claude Code with Docker Building"
echo "   Inside container:"
echo "   Run: claude 'Create a simple Node.js web server with Dockerfile'"
echo "   Expected: Claude creates files and you can build them with Docker"
echo ""

echo "✅ Quick Verification Commands:"
echo "   ./run.sh build && echo 'Build: OK'"
echo "   ./run.sh start && echo 'Start: OK'"
echo "   docker-compose exec claude-code echo 'Access: OK'"
echo "   docker-compose exec claude-code docker --version && echo 'Docker-in-Docker: OK'"
echo "   docker-compose exec claude-code claude --version && echo 'Claude Code: OK'"
echo "   ./run.sh stop && echo 'Stop: OK'"
echo ""

echo "🚨 Troubleshooting:"
echo "   - If build fails: Check internet connection and Docker daemon"
echo "   - If start fails: Check ports 3000/8080 aren't in use"
echo "   - If Docker-in-Docker fails: Try DinD mode instead"
echo "   - If Claude Code fails: Check API key in .env file"
echo ""

echo "📝 All Test Commands Summary:"
cat << 'EOF'

# Test sequence
docker --version
docker-compose --version
cp .env.example .env
# Edit .env with your API key
./run.sh build
./run.sh start
./run.sh status
./run.sh shell
# Inside container:
whoami
docker --version
claude --version
cd /workspace
echo 'FROM alpine:latest' > Dockerfile
docker build -t test .
docker run --rm test
exit
# Back on host:
./run.sh stop

EOF

echo "🎯 Run './run.sh help' for all available commands!"
echo "🐳 Happy testing!"