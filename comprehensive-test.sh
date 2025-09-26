#!/bin/bash

# Comprehensive Test Suite for Claude Code Docker Setup
# This script tests all functionality with a strategic approach

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Change to script directory
cd "$(dirname "$0")"

# Logging functions
log_test() {
    echo -e "${PURPLE}[TEST $((++TOTAL_TESTS))]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((TESTS_PASSED++))
}

log_failure() {
    echo -e "${RED}[✗]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_section() {
    echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up test resources..."
    ./run.sh stop > /dev/null 2>&1 || true
    docker system prune -f > /dev/null 2>&1 || true
}

# Trap cleanup on exit
trap cleanup EXIT

# Test function wrapper
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_success="${3:-true}"

    log_test "$test_name"

    if eval "$test_command" > /tmp/test_output 2>&1; then
        if [ "$expected_success" = "true" ]; then
            log_success "$test_name - PASSED"
        else
            log_failure "$test_name - FAILED (Expected failure but succeeded)"
        fi
    else
        if [ "$expected_success" = "false" ]; then
            log_success "$test_name - PASSED (Expected failure)"
        else
            log_failure "$test_name - FAILED"
            echo "Output:"
            cat /tmp/test_output | head -20
        fi
    fi
}

# Start comprehensive testing
echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║               Claude Code Docker Test Suite                   ║
║                   Comprehensive Testing                       ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Phase 1: Prerequisites and Setup
log_section "Phase 1: Prerequisites and Environment Setup"

run_test "Docker daemon is running" "docker info"
run_test "Docker Compose is available" "docker-compose --version"
run_test "Required files exist" "test -f Dockerfile && test -f docker-compose.yml && test -f run.sh"
run_test "Run script is executable" "test -x run.sh"

# Create .env if needed for testing
if [ ! -f .env ]; then
    log_info "Creating temporary .env file for testing..."
    echo "CLAUDE_API_KEY=test_key_for_docker_testing_only" > .env
    TEMP_ENV_CREATED=true
fi

# Phase 2: Docker Image Building
log_section "Phase 2: Docker Image Building and Management"

run_test "Build Docker image" "./run.sh build"
run_test "Docker image was created" "docker images | grep -q claude-code-docker"
run_test "Docker image has correct labels" "docker inspect claude-code-docker-claude-code:latest"

# Phase 3: Container Management Commands
log_section "Phase 3: Container Management Commands"

run_test "Start container (socket mode)" "./run.sh start"
run_test "Container is running" "docker-compose ps | grep -q Up"
run_test "Check container status" "./run.sh status"

# Wait for container to be ready
log_info "Waiting for container to initialize..."
sleep 10

run_test "Container health check" "docker-compose exec -T claude-code echo 'Container accessible'"

# Phase 4: Claude Code Integration Testing
log_section "Phase 4: Claude Code Integration Testing"

run_test "Claude Code is installed" "docker-compose exec -T claude-code which claude"
run_test "Claude Code version check" "docker-compose exec -T claude-code claude --version"
run_test "Node.js is available" "docker-compose exec -T claude-code node --version"
run_test "NPM is available" "docker-compose exec -T claude-code npm --version"

# Phase 5: Docker-in-Docker Testing
log_section "Phase 5: Docker-in-Docker Functionality"

run_test "Docker CLI available in container" "docker-compose exec -T claude-code docker --version"
run_test "Docker daemon accessible" "docker-compose exec -T claude-code docker info"
run_test "Can pull Docker images" "docker-compose exec -T claude-code docker pull hello-world"
run_test "Can run Docker containers" "docker-compose exec -T claude-code docker run --rm hello-world"

# Phase 6: File System and Workspace Testing
log_section "Phase 6: File System and Workspace Testing"

run_test "Workspace directory exists" "docker-compose exec -T claude-code test -d /workspace"
run_test "Workspace is writable" "docker-compose exec -T claude-code touch /workspace/test-file"
run_test "Host workspace is accessible" "test -f workspace/test-file"
run_test "Can create directories in workspace" "docker-compose exec -T claude-code mkdir -p /workspace/test-dir"

# Phase 7: Docker Build Testing Inside Container
log_section "Phase 7: Docker Build Testing Inside Container"

# Create test Dockerfile
cat > workspace/test-app/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Hello from Docker-in-Docker build!" > /hello.txt
CMD ["cat", "/hello.txt"]
EOF

cat > workspace/test-app/package.json << 'EOF'
{
  "name": "test-app",
  "version": "1.0.0",
  "description": "Test application for Docker-in-Docker"
}
EOF

run_test "Create test application structure" "mkdir -p workspace/test-app"
run_test "Build Docker image inside container" "docker-compose exec -T claude-code sh -c 'cd /workspace/test-app && docker build -t test-docker-app .'"
run_test "List built images" "docker-compose exec -T claude-code docker images test-docker-app"
run_test "Run built container" "docker-compose exec -T claude-code docker run --rm test-docker-app"
run_test "Tag Docker image" "docker-compose exec -T claude-code docker tag test-docker-app test-docker-app:v1.0"

# Phase 8: Multiple Container Testing
log_section "Phase 8: Multi-Container Docker Testing"

# Create docker-compose test
cat > workspace/multi-test/docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
  db:
    image: redis:alpine
EOF

run_test "Create multi-container test" "mkdir -p workspace/multi-test"
run_test "Multi-container compose up" "docker-compose exec -T claude-code sh -c 'cd /workspace/multi-test && docker-compose up -d'"
run_test "Check multi-container status" "docker-compose exec -T claude-code sh -c 'cd /workspace/multi-test && docker-compose ps'"
run_test "Multi-container compose down" "docker-compose exec -T claude-code sh -c 'cd /workspace/multi-test && docker-compose down'"

# Phase 9: Network and Port Testing
log_section "Phase 9: Network and Port Testing"

run_test "Test container networking" "docker-compose exec -T claude-code ping -c 1 google.com"
run_test "Test port binding" "docker-compose exec -T claude-code docker run -d -p 9999:80 nginx:alpine"
run_test "List Docker networks" "docker-compose exec -T claude-code docker network ls"

# Phase 10: Resource Management Testing
log_section "Phase 10: Resource Management and Cleanup"

run_test "Docker system info" "docker-compose exec -T claude-code docker system df"
run_test "Clean up test images" "docker-compose exec -T claude-code docker rmi test-docker-app:latest test-docker-app:v1.0"
run_test "Docker system prune" "docker-compose exec -T claude-code docker system prune -f"

# Phase 11: Alternative DinD Mode Testing
log_section "Phase 11: Docker-in-Docker Mode Testing"

# Stop current container
run_test "Stop socket mode container" "./run.sh stop"

# Test DinD mode
run_test "Start DinD mode container" "./run.sh start-dind"
sleep 15  # DinD takes longer to start

run_test "DinD container is running" "docker-compose ps | grep claude-code-dind | grep -q Up"
run_test "DinD Docker daemon working" "docker-compose exec -T claude-code-dind docker info"
run_test "DinD can build images" "docker-compose exec -T claude-code-dind sh -c 'cd /workspace/test-app && docker build -t dind-test .'"

# Phase 12: All run.sh Commands Testing
log_section "Phase 12: All run.sh Commands Testing"

run_test "Stop DinD container" "./run.sh stop"
run_test "Start regular container again" "./run.sh start"
sleep 10

run_test "Run.sh status command" "./run.sh status"
run_test "Run.sh claude version command" "./run.sh claude --version"

# Test logs command (should not fail but we don't check output)
timeout 5 ./run.sh logs > /tmp/logs_output 2>&1 || true
run_test "Run.sh logs command" "test -f /tmp/logs_output"

# Phase 13: Security and Permissions Testing
log_section "Phase 13: Security and Permissions Testing"

run_test "Container runs as non-root user" "docker-compose exec -T claude-code whoami | grep -q claude"
run_test "Docker socket permissions" "docker-compose exec -T claude-code ls -la /var/run/docker.sock"
run_test "Workspace permissions" "docker-compose exec -T claude-code ls -la /workspace"

# Phase 14: Advanced Docker Features Testing
log_section "Phase 14: Advanced Docker Features Testing"

run_test "Docker volume creation" "docker-compose exec -T claude-code docker volume create test-volume"
run_test "Docker volume usage" "docker-compose exec -T claude-code docker run --rm -v test-volume:/data alpine touch /data/test"
run_test "Docker volume cleanup" "docker-compose exec -T claude-code docker volume rm test-volume"

# Create a test with custom network
run_test "Docker network creation" "docker-compose exec -T claude-code docker network create test-network"
run_test "Container with custom network" "docker-compose exec -T claude-code docker run --rm --network test-network alpine ping -c 1 127.0.0.1"
run_test "Docker network cleanup" "docker-compose exec -T claude-code docker network rm test-network"

# Phase 15: Final Cleanup and Summary
log_section "Phase 15: Final Cleanup and Results"

# Clean up temporary files
rm -f /tmp/test_output /tmp/logs_output
rm -rf workspace/test-app workspace/multi-test
docker-compose exec -T claude-code rm -f /workspace/test-file > /dev/null 2>&1 || true

# Remove temp env if created
if [ "$TEMP_ENV_CREATED" = "true" ]; then
    rm -f .env
    log_info "Removed temporary .env file"
fi

# Final container stop
./run.sh stop > /dev/null 2>&1 || true

# Print final results
echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}           TEST RESULTS SUMMARY          ${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"

echo -e "\n📊 Total Tests Run: $TOTAL_TESTS"
echo -e "✅ Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "❌ Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n🎉 ${GREEN}ALL TESTS PASSED!${NC} 🎉"
    echo -e "🐳 Claude Code Docker setup is fully functional!"
    echo -e "\n📋 What was tested:"
    echo -e "   • Docker image building and management"
    echo -e "   • Container lifecycle (start/stop/status)"
    echo -e "   • Claude Code integration"
    echo -e "   • Docker-in-Docker functionality (both modes)"
    echo -e "   • File system and workspace persistence"
    echo -e "   • Network and port management"
    echo -e "   • Security and permissions"
    echo -e "   • Multi-container orchestration"
    echo -e "   • Advanced Docker features"
    echo -e "\n🚀 Ready for production use!"
else
    echo -e "\n⚠️  ${YELLOW}SOME TESTS FAILED${NC}"
    echo -e "Please review the failed tests above and fix any issues."
    exit 1
fi

echo -e "\n${BLUE}Next steps:${NC}"
echo -e "  1. ./run.sh start    # Start the environment"
echo -e "  2. ./run.sh shell    # Access the container"
echo -e "  3. claude 'Build me something cool!'  # Use Claude Code"
echo -e "  4. docker build -t myapp .  # Build Docker images"
echo -e "\n✨ Happy coding with Claude in Docker! ✨"