# Claude Code Docker Container with Docker-in-Docker support
FROM node:20-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    tree \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI and Docker-in-Docker with enhanced retry logic
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && (apt-get install -y --fix-missing --no-install-recommends \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    || (sleep 10 && apt-get update && apt-get install -y --fix-missing --allow-downgrades \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin) \
    || (sleep 20 && apt-get update && apt --fix-broken install -y && apt-get install -y --fix-missing \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)) \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@latest

# Create workspace directory
WORKDIR /workspace

# Create a non-root user for security
RUN useradd -m -s /bin/bash claude \
    && usermod -aG docker claude \
    && chown -R claude:claude /workspace

# Switch to non-root user
USER claude

# Set up environment variables
ENV CLAUDE_API_KEY=""
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Expose port for any web services
EXPOSE 3000 8080

# Create startup script
USER root
RUN echo '#!/bin/bash\n\
# Start Docker daemon if not running\n\
if ! pgrep dockerd > /dev/null; then\n\
    dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2376 &\n\
    sleep 5\n\
fi\n\
\n\
# Switch to claude user and start shell or run command\n\
if [ "$#" -eq 0 ]; then\n\
    exec su - claude\n\
else\n\
    exec su - claude -c "$*"\n\
fi' > /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/start.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["/bin/bash"]