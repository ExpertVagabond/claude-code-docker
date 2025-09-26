# 🔒 Claude Code Docker Security Guide

## Overview

This document outlines security best practices, threat model, and hardening measures for the Claude Code Docker environment.

## 🎯 Security Model

### What We Protect Against
- **Unauthorized host access** via container escape
- **API key exposure** in logs or version control
- **Privilege escalation** within containers
- **Network attacks** from external sources
- **Resource exhaustion** attacks

### What We Don't Protect Against
- **Host-level vulnerabilities** (OS, kernel, Docker daemon)
- **Social engineering** attacks on API keys
- **Physical access** to host machine
- **Advanced persistent threats** with root access

## 🛡️ Security Features Implemented

### Container Security
- ✅ **Non-root user**: Container runs as `claude` user (UID 1000)
- ✅ **Capability dropping**: Drops all capabilities except SYS_ADMIN
- ✅ **No-new-privileges**: Prevents privilege escalation
- ✅ **Resource limits**: Memory (2GB) and CPU (2 cores) limits
- ✅ **Health checks**: Monitors container health
- ✅ **Seccomp profile**: Allows Docker operations while blocking dangerous syscalls

### Network Security
- ✅ **Network isolation**: Uses dedicated Docker network
- ✅ **Port restrictions**: Only exposes necessary ports
- ✅ **Localhost binding**: Docker daemon port bound to localhost only
- ✅ **Configurable ports**: Environment-based port configuration

### API Key Security
- ✅ **Environment variables**: No hardcoded keys
- ✅ **File permissions**: .env files have 600 permissions
- ✅ **Template system**: Secure configuration templates
- ✅ **Rotation support**: Easy key rotation process

### Docker-in-Docker Security
- ✅ **Socket mounting**: Shares host Docker daemon (more secure than full DinD)
- ✅ **Limited access**: No privileged mode required
- ✅ **Audit trail**: All Docker operations logged by host daemon

## 🚨 Security Risks & Mitigations

### High Risk

| Risk | Mitigation | Status |
|------|------------|---------|
| **Docker socket access** | Use socket mounting instead of DinD | ✅ Implemented |
| **Container escape** | Non-root user, capability dropping | ✅ Implemented |
| **API key exposure** | Environment variables, secure file permissions | ✅ Implemented |

### Medium Risk

| Risk | Mitigation | Status |
|------|------------|---------|
| **Resource exhaustion** | Memory and CPU limits | ✅ Implemented |
| **Network attacks** | Network isolation, port restrictions | ✅ Implemented |
| **Image vulnerabilities** | Regular base image updates | 📋 Manual process |

### Low Risk

| Risk | Mitigation | Status |
|------|------------|---------|
| **Log information leakage** | Structured logging, log rotation | 🔄 In progress |
| **Workspace pollution** | Isolated workspace, .dockerignore | ✅ Implemented |

## 🔧 Setup Security

### 1. Initial Security Setup
```bash
# Run the security setup script
./security-setup.sh

# Review and customize security settings
vim .env
```

### 2. API Key Security
```bash
# Use a dedicated API key for Docker development
export CLAUDE_API_KEY="sk-ant-api03-your-secure-key"

# Set secure permissions
chmod 600 .env

# Never commit .env files
echo ".env" >> .gitignore
```

### 3. Network Security
```bash
# Production: Bind Docker port to localhost only
export DOCKER_PORT="127.0.0.1:2376"

# Development: Use custom ports to avoid conflicts
export WEB_PORT="3000"
export DEV_PORT="8080"
```

## 🔍 Security Monitoring

### Regular Security Checks
```bash
# Run security validation
./security-check.sh

# Check container security
docker exec claude-code-dev whoami  # Should show: claude
docker exec claude-code-dev id       # Should show non-root UID

# Monitor resource usage
docker stats claude-code-dev

# Check capabilities
docker exec claude-code-dev cat /proc/1/status | grep Cap
```

### Log Monitoring
```bash
# Monitor container logs
./run.sh logs

# Check Docker daemon logs
sudo journalctl -u docker.service

# Monitor network connections
docker exec claude-code-dev netstat -tuln
```

## 🚀 Production Security

### Environment Separation
```bash
# Production environment
export ENVIRONMENT=production
export LOG_LEVEL=warn
export WORKSPACE_READ_ONLY=true

# Disable development ports
unset DEV_PORT
unset DOCKER_PORT
```

### Backup and Recovery
```bash
# Backup workspace
docker run --rm -v claude-code-docker_claude-home:/data alpine tar czf /backup/claude-workspace.tar.gz /data

# Backup configuration
cp .env .env.backup.$(date +%Y%m%d)
```

### Regular Maintenance
```bash
# Update base images monthly
docker pull node:20-bullseye
./run.sh build --no-cache

# Rotate API keys quarterly
# Update .env with new key
# Test with: claude --version

# Review security settings
./security-check.sh
```

## 🆘 Security Incident Response

### If API Key is Compromised
1. **Immediately revoke** the compromised key in Anthropic console
2. **Generate new key** with limited scope
3. **Update .env** with new key
4. **Rebuild container**: `./run.sh build`
5. **Review logs** for unauthorized usage

### If Container is Compromised
1. **Stop container immediately**: `./run.sh stop`
2. **Inspect logs**: `./run.sh logs`
3. **Check host security**: `docker system events`
4. **Rebuild from scratch**: `./run.sh build --no-cache`
5. **Review network access**: Check firewall rules

### If Host Docker is Compromised
1. **Isolate host** from network
2. **Stop all containers**: `docker stop $(docker ps -q)`
3. **Backup critical data**
4. **Reinstall Docker** or entire host
5. **Restore from clean backups**

## 📋 Security Checklist

### Before First Use
- [ ] Run `./security-setup.sh`
- [ ] Add real API key to `.env`
- [ ] Review security settings
- [ ] Test with `./security-check.sh`

### Regular Maintenance (Monthly)
- [ ] Update base images
- [ ] Review security logs
- [ ] Check for CVEs in dependencies
- [ ] Test backup/restore procedures

### Before Production Use
- [ ] Set `ENVIRONMENT=production`
- [ ] Enable read-only workspace
- [ ] Restrict network access
- [ ] Setup monitoring/alerting
- [ ] Document incident response

## 🔗 Security Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Container Runtime Security](https://kubernetes.io/docs/concepts/security/)
- [Anthropic API Security](https://docs.anthropic.com/claude/docs/security)
- [OWASP Container Security](https://owasp.org/www-project-container-security/)

## 📞 Security Contact

For security issues or questions:
- Review this documentation
- Run `./security-check.sh` for diagnostics
- Check container logs: `./run.sh logs`
- Open GitHub issue with security details (no secrets!)

---

**Remember**: Security is a process, not a destination. Regular reviews and updates are essential.