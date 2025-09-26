# Claude Code Docker Setup

This Docker setup provides an isolated environment for running Claude Code with Docker-in-Docker capabilities, allowing you to build and manage Docker images from within Claude Code.

## Features

- 🐳 **Docker-in-Docker Support**: Build and run Docker containers from within Claude Code
- 🔒 **Isolated Environment**: Run Claude Code in a secure, containerized environment
- ⛓️  **Blockchain Integration**: Full MCP support with Universal Blockchain, ZetaChain, Solana, and Sui tools
- 🤖 **MCP Server Support**: Connect to any Model Context Protocol servers
- 📁 **Persistent Workspace**: Your work is saved in a mounted workspace directory
- ⚡ **Easy Management**: Simple scripts for building, starting, and managing containers
- 🛡️ **Security**: Runs as non-root user with proper permissions
- 🔧 **Two Modes**: Socket mounting (recommended) or full Docker-in-Docker

## Quick Start

### 1. Setup Environment

```bash
cd claude-code-docker
cp .env.example .env
# Edit .env and add your CLAUDE_API_KEY
```

### 2. Build and Start

```bash
# Build the Docker image
./run.sh build

# Start the container
./run.sh start

# Access the container shell
./run.sh shell
```

### 3. Use Claude Code

Once inside the container, you can use Claude Code normally:

```bash
# Check if Claude Code is working
claude --version

# Start an interactive session
claude

# Run a specific command
claude "Create a simple Node.js web server"
```

### 4. Build Docker Images

Inside the container, you can build Docker images:

```bash
# Create a simple Dockerfile
echo 'FROM nginx:alpine' > Dockerfile

# Build an image
docker build -t my-nginx .

# List images
docker images

# Run a container
docker run -d -p 8080:80 my-nginx
```

## Available Commands

```bash
./run.sh build           # Build the Docker image
./run.sh start           # Start container (Docker socket mode)
./run.sh start-dind      # Start container (Docker-in-Docker mode)
./run.sh stop            # Stop containers
./run.sh shell           # Access container shell
./run.sh shell-dind      # Access DinD container shell
./run.sh status          # Show container status
./run.sh logs            # View container logs
./run.sh claude [args]   # Run Claude Code command
./run.sh clean           # Clean up Docker resources
./run.sh help            # Show help
```

## Docker Modes

### Mode 1: Docker Socket Mounting (Recommended)

This mode mounts the host's Docker socket, allowing the container to use the host's Docker daemon:

```bash
./run.sh start
./run.sh shell
```

**Pros:**
- Faster startup
- Uses host Docker daemon
- Shares images with host

**Cons:**
- Less isolation
- Requires Docker socket access

### Mode 2: Docker-in-Docker (Full Isolation)

This mode runs a complete Docker daemon inside the container:

```bash
./run.sh start-dind
./run.sh shell-dind
```

**Pros:**
- Complete isolation
- Own Docker daemon
- More secure

**Cons:**
- Slower startup
- More resource usage
- Separate image storage

## Directory Structure

```
claude-code-docker/
├── Dockerfile              # Main container definition
├── docker-compose.yml      # Multi-container setup
├── run.sh                  # Management script
├── .env.example            # Environment template
├── .dockerignore           # Docker ignore patterns
├── workspace/              # Your persistent workspace
└── README.md               # This file
```

## Environment Variables

Create a `.env` file with:

```bash
# Required: Your Claude API key
CLAUDE_API_KEY=your_api_key_here

# Optional: Development settings
NODE_ENV=development
DEBUG=*
```

## Port Mappings

- `3000`: Default web service port
- `8080`: Alternative web service port
- `2376`: Docker daemon port (DinD mode)

## Volume Mounts

- `./workspace:/workspace` - Your persistent development workspace
- `/var/run/docker.sock:/var/run/docker.sock` - Docker socket (socket mode)
- `claude-home:/home/claude` - User home directory

## Troubleshooting

### Permission Issues

If you encounter permission issues with Docker:

```bash
# Check if Docker is running
docker ps

# Restart the container
./run.sh stop && ./run.sh start

# Try DinD mode instead
./run.sh start-dind
```

### API Key Issues

Make sure your `.env` file contains a valid Claude API key:

```bash
# Check your .env file
cat .env

# Test Claude Code
./run.sh claude --version
```

### Container Issues

```bash
# Check container status
./run.sh status

# View logs
./run.sh logs

# Clean restart
./run.sh clean && ./run.sh build && ./run.sh start
```

## Security Notes

- The container runs as a non-root user (`claude`)
- Docker socket mounting requires privileged access
- Consider using DinD mode for better isolation in production
- Never commit your `.env` file with real API keys

## Development Workflow

1. **Start Environment**: `./run.sh build && ./run.sh start`
2. **Access Shell**: `./run.sh shell`
3. **Use Claude Code**: `claude "your request"`
4. **Build Docker Images**: Use normal `docker` commands
5. **Persist Work**: Save files in `/workspace`

## Integration Examples

### Building a Web App

```bash
# Inside the container
cd /workspace
claude "Create a Express.js web server with Docker support"
# Claude will create the app and Dockerfile
docker build -t my-web-app .
docker run -p 3000:3000 my-web-app
```

### Multi-Container Development

```bash
# Create docker-compose.yml for your app
claude "Create a docker-compose.yml for a Node.js app with Redis"
docker-compose up -d
```

## Contributing

To improve this setup:

1. Fork the repository
2. Make changes to Docker configuration
3. Test with `./run.sh build && ./run.sh start`
4. Submit pull request

## Support

For issues:
- Check container logs: `./run.sh logs`
- Verify Docker installation: `docker --version`
- Test Claude API key: `./run.sh claude --version`