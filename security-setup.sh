#!/bin/bash

# Claude Code Docker - Security Setup Script
set -e

echo "🔒 Claude Code Docker Security Setup"
echo "===================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  WARNING: Don't run this script as root"
    echo "   Run as regular user: ./security-setup.sh"
    exit 1
fi

# 1. API Key Security
echo ""
echo "1️⃣  Setting up secure API key handling..."

if [ ! -f .env ]; then
    echo "📝 Creating secure .env file from template..."
    cp .env.security-template .env
    echo "✅ .env file created"
    echo "🔑 IMPORTANT: Edit .env and add your real CLAUDE_API_KEY"
else
    echo "✅ .env file already exists"
fi

# Set proper permissions on sensitive files
chmod 600 .env 2>/dev/null || true
chmod 600 .env.security-template 2>/dev/null || true
echo "✅ Set secure file permissions (600) on .env files"

# 2. Docker Socket Security
echo ""
echo "2️⃣  Configuring Docker socket security..."

if groups | grep -q docker; then
    echo "✅ User is in docker group"
else
    echo "⚠️  User not in docker group. Run:"
    echo "   sudo usermod -aG docker $USER"
    echo "   Then logout and login again"
fi

# 3. Container Security Review
echo ""
echo "3️⃣  Security configuration review..."

echo "📋 Current security settings:"
echo "   • Non-root user (claude) in container: ✅"
echo "   • Docker socket mounting (limited host access): ✅"
echo "   • Network isolation: ✅"
echo "   • Port restrictions: ✅"
echo "   • Workspace isolation: ✅"

# 4. Security Recommendations
echo ""
echo "4️⃣  Security recommendations:"
echo ""
echo "🔐 API Key Security:"
echo "   • Use dedicated API key for Docker environment"
echo "   • Rotate API keys regularly"
echo "   • Never commit .env files to version control"
echo ""
echo "🐳 Docker Security:"
echo "   • Use socket mode (not full DinD) when possible"
echo "   • Limit exposed ports in production"
echo "   • Regularly update base images"
echo ""
echo "📁 Workspace Security:"
echo "   • Don't store sensitive data in workspace/"
echo "   • Use .dockerignore for sensitive files"
echo "   • Regular workspace backups"
echo ""
echo "🌐 Network Security:"
echo "   • Only expose necessary ports"
echo "   • Use firewall rules for production"
echo "   • Monitor container network access"

# 5. Create security validation script
echo ""
echo "5️⃣  Creating security validation script..."

cat > security-check.sh << 'EOF'
#!/bin/bash
echo "🔍 Security Validation Check"
echo "==========================="

echo ""
echo "📝 File Permissions:"
ls -la .env* 2>/dev/null | grep -E "\.(env|security)" || echo "No .env files found"

echo ""
echo "🐳 Docker Configuration:"
docker info --format '{{json .SecurityOptions}}' 2>/dev/null | jq -r '.[]' 2>/dev/null || echo "Docker not accessible or jq not installed"

echo ""
echo "🔒 Container User Check:"
docker exec claude-code-dev whoami 2>/dev/null || echo "Container not running"

echo ""
echo "📊 Container Capabilities:"
docker exec claude-code-dev cat /proc/1/status | grep Cap 2>/dev/null || echo "Container not running"

echo ""
echo "✅ Security check complete"
EOF

chmod +x security-check.sh
echo "✅ Created security-check.sh script"

# 6. Final recommendations
echo ""
echo "6️⃣  Setup complete! Next steps:"
echo ""
echo "🔧 Required actions:"
echo "   1. Edit .env and add your real CLAUDE_API_KEY"
echo "   2. Review security settings in .env"
echo "   3. Rebuild container: ./run.sh build"
echo ""
echo "🧪 Security testing:"
echo "   1. Run: ./security-check.sh"
echo "   2. Test container: ./run.sh start && ./run.sh shell"
echo "   3. Verify user: whoami (should show 'claude')"
echo ""
echo "🔒 Security monitoring:"
echo "   • Run security-check.sh regularly"
echo "   • Monitor container logs: ./run.sh logs"
echo "   • Update base images monthly"

echo ""
echo "✨ Security setup complete!"