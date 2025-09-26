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
