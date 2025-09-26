#!/bin/bash

# Validate Claude Code Docker Setup
# Checks all files and configurations without building

set -e
cd "$(dirname "$0")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

passed=0
failed=0

check() {
    local test_name="$1"
    local condition="$2"

    printf "%-50s" "$test_name"

    if eval "$condition" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((passed++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((failed++))
    fi
}

echo -e "${BLUE}🔍 Claude Code Docker Setup Validation${NC}"
echo "======================================="
echo ""

echo -e "${YELLOW}📋 Prerequisites:${NC}"
check "Docker installed" "command -v docker"
check "Docker Compose installed" "command -v docker-compose"
check "Docker daemon running" "docker info"

echo ""
echo -e "${YELLOW}📁 Core Files:${NC}"
check "Dockerfile exists" "test -f Dockerfile"
check "docker-compose.yml exists" "test -f docker-compose.yml"
check "run.sh exists" "test -f run.sh"
check "run.sh executable" "test -x run.sh"
check ".env.example exists" "test -f .env.example"
check ".dockerignore exists" "test -f .dockerignore"
check "README.md exists" "test -f README.md"

echo ""
echo -e "${YELLOW}🛠  Scripts and Tools:${NC}"
check "comprehensive-test.sh exists" "test -f comprehensive-test.sh"
check "comprehensive-test.sh executable" "test -x comprehensive-test.sh"
check "quick-test.sh exists" "test -f quick-test.sh"
check "quick-test.sh executable" "test -x quick-test.sh"
check "manual-test.sh exists" "test -f manual-test.sh"
check "manual-test.sh executable" "test -x manual-test.sh"
check "test-setup.sh exists" "test -f test-setup.sh"
check "test-setup.sh executable" "test -x test-setup.sh"

echo ""
echo -e "${YELLOW}📂 Workspace Structure:${NC}"
check "workspace directory exists" "test -d workspace"
check "docker-examples directory exists" "test -d workspace/docker-examples"
check "simple-web-app example" "test -f workspace/docker-examples/simple-web-app/Dockerfile"
check "multi-stage example" "test -f workspace/docker-examples/multi-stage/Dockerfile"
check "compose-example" "test -f workspace/docker-examples/compose-example/docker-compose.yml"
check "test-dockerfile exists" "test -f workspace/test-dockerfile"

echo ""
echo -e "${YELLOW}⚙️  Configuration Validation:${NC}"

# Check Dockerfile structure
check "Dockerfile has Node.js base" "grep -q 'FROM node:20-bullseye' Dockerfile"
check "Dockerfile installs Docker" "grep -q 'docker-ce' Dockerfile"
check "Dockerfile installs Claude Code" "grep -q 'claude-code' Dockerfile"
check "Dockerfile creates claude user" "grep -q 'useradd.*claude' Dockerfile"
check "Dockerfile sets workdir" "grep -q 'WORKDIR /workspace' Dockerfile"

# Check docker-compose structure
check "docker-compose has claude-code service" "grep -q 'claude-code:' docker-compose.yml"
check "docker-compose has privileged mode" "grep -q 'privileged: true' docker-compose.yml"
check "docker-compose has workspace volume" "grep -q './workspace:/workspace' docker-compose.yml"
check "docker-compose has docker socket" "grep -q '/var/run/docker.sock' docker-compose.yml"
check "docker-compose has DinD profile" "grep -q 'profiles:' docker-compose.yml"

# Check run.sh functionality
check "run.sh has build command" "grep -q 'build)' run.sh"
check "run.sh has start command" "grep -q 'start)' run.sh"
check "run.sh has stop command" "grep -q 'stop)' run.sh"
check "run.sh has shell command" "grep -q 'shell)' run.sh"
check "run.sh has status command" "grep -q 'status)' run.sh"
check "run.sh has claude command" "grep -q 'claude)' run.sh"

echo ""
echo -e "${YELLOW}🔐 Security Checks:${NC}"
check "Non-root user in Dockerfile" "grep -q 'USER claude' Dockerfile"
check "Docker group membership" "grep -q 'usermod.*docker.*claude' Dockerfile"
check ".env in .dockerignore" "grep -q '\.env' .dockerignore"
check ".git in .dockerignore" "grep -q '\.git' .dockerignore"

echo ""
echo -e "${YELLOW}📚 Documentation:${NC}"
check "README has features section" "grep -q 'Features' README.md"
check "README has quick start" "grep -q 'Quick Start' README.md"
check "README has commands list" "grep -q 'Available Commands' README.md"
check "README has troubleshooting" "grep -q 'Troubleshooting' README.md"

echo ""
echo "======================================="
echo -e "${BLUE}📊 Validation Results:${NC}"
echo -e "✅ Passed: ${GREEN}$passed${NC}"
echo -e "❌ Failed: ${RED}$failed${NC}"
total=$((passed + failed))
echo -e "📈 Total: $total tests"

if [ $failed -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All validations passed!${NC}"
    echo -e "${GREEN}✨ Your Claude Code Docker setup is properly configured.${NC}"
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "1. Add your Claude API key to .env:"
    echo "   cp .env.example .env"
    echo "   # Edit .env and add CLAUDE_API_KEY=your_key_here"
    echo ""
    echo "2. Build and start:"
    echo "   ./run.sh build    # May take 5-10 minutes first time"
    echo "   ./run.sh start    # Starts the container"
    echo "   ./run.sh shell    # Access container shell"
    echo ""
    echo "3. Test functionality:"
    echo "   # Inside container:"
    echo "   claude --version"
    echo "   docker --version"
    echo "   claude 'Create a simple web app with Dockerfile'"
    echo ""
    echo -e "${YELLOW}💡 Pro Tips:${NC}"
    echo "• Use ./run.sh help for all commands"
    echo "• Use ./manual-test.sh for step-by-step testing"
    echo "• Use ./quick-test.sh for automated testing"
    echo "• Use ./comprehensive-test.sh for full validation"
else
    echo ""
    echo -e "${RED}⚠️  Some validations failed.${NC}"
    echo "Please check the failed items above and ensure all files are properly created."
    exit 1
fi