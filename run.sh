#!/bin/bash

# Claude Code Docker Runner Script
# This script provides easy commands to manage the Claude Code Docker environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
check_env_file() {
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        cp .env.example .env
        print_warning "Please edit .env file and add your CLAUDE_API_KEY"
        return 1
    fi

    # Check if CLAUDE_API_KEY is set
    if ! grep -q "^CLAUDE_API_KEY=" .env || grep -q "^CLAUDE_API_KEY=your_claude_api_key_here" .env; then
        print_error "CLAUDE_API_KEY not set in .env file"
        return 1
    fi

    return 0
}

# Create workspace directory if it doesn't exist
setup_workspace() {
    if [ ! -d "workspace" ]; then
        print_status "Creating workspace directory..."
        mkdir -p workspace
        print_success "Workspace directory created"
    fi
}

# Function to build the Docker image
build() {
    print_status "Building Claude Code Docker image..."
    docker-compose build claude-code
    print_success "Docker image built successfully"
}

# Function to start the container
start() {
    check_env_file || return 1
    setup_workspace

    print_status "Starting Claude Code container..."
    docker-compose up -d claude-code
    print_success "Container started successfully"
    print_status "Use './run.sh shell' to access the container shell"
    print_status "Use './run.sh logs' to view container logs"
}

# Function to start with Docker-in-Docker
start_dind() {
    check_env_file || return 1
    setup_workspace

    print_status "Starting Claude Code container with Docker-in-Docker..."
    docker-compose --profile dind up -d claude-code-dind
    print_success "DinD container started successfully"
    print_status "Use './run.sh shell-dind' to access the container shell"
}

# Function to access container shell
shell() {
    print_status "Accessing Claude Code container shell..."
    docker-compose exec claude-code /bin/bash
}

# Function to access DinD container shell
shell_dind() {
    print_status "Accessing Claude Code DinD container shell..."
    docker-compose exec claude-code-dind /bin/bash
}

# Function to stop containers
stop() {
    print_status "Stopping Claude Code containers..."
    docker-compose down
    print_success "Containers stopped"
}

# Function to view logs
logs() {
    docker-compose logs -f claude-code
}

# Function to clean up
clean() {
    print_status "Cleaning up Docker resources..."
    docker-compose down -v --rmi all
    print_success "Cleanup completed"
}

# Function to show status
status() {
    print_status "Container status:"
    docker-compose ps
}

# Function to run Claude Code command
claude() {
    if [ $# -eq 0 ]; then
        print_status "Starting interactive Claude Code session..."
        docker-compose exec claude-code claude
    else
        print_status "Running Claude Code command: $*"
        docker-compose exec claude-code claude "$@"
    fi
}

# Function to show usage
usage() {
    cat << EOF
Claude Code Docker Runner

Usage: ./run.sh [command]

Commands:
    build           Build the Docker image
    start           Start the container (default mode with Docker socket)
    start-dind      Start with Docker-in-Docker (alternative mode)
    stop            Stop all containers
    shell           Access container shell (default mode)
    shell-dind      Access DinD container shell
    status          Show container status
    logs            View container logs
    claude [args]   Run Claude Code command in container
    clean           Clean up all Docker resources
    help            Show this help message

Examples:
    ./run.sh build && ./run.sh start
    ./run.sh shell
    ./run.sh claude --version
    ./run.sh claude "Build a simple web server"

Setup:
1. Copy .env.example to .env
2. Add your CLAUDE_API_KEY to .env
3. Run: ./run.sh build && ./run.sh start
4. Access: ./run.sh shell

EOF
}

# Main command handler
case "${1:-}" in
    build)
        build
        ;;
    start)
        start
        ;;
    start-dind)
        start_dind
        ;;
    stop)
        stop
        ;;
    shell)
        shell
        ;;
    shell-dind)
        shell_dind
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    claude)
        shift
        claude "$@"
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        print_error "Unknown command: ${1:-}"
        echo
        usage
        exit 1
        ;;
esac