# Docker Containers and Services

This directory contains Docker configurations for various self-hosted services and applications.

## Services Overview

- **lab-web/** - Simple test web application for Docker learning and testing
- **pi-hole-server/** - Pi-hole DNS ad-blocker server configuration
- **plex-server/** - Plex media server for streaming personal media
- **uptime-kuma/** - Uptime monitoring and status page service

## Common Features

- **Docker Compose** - Most services use docker-compose for easy deployment
- **Volume Persistence** - Data volumes configured for persistent storage
- **Network Configuration** - Proper port mappings and network settings
- **Environment Variables** - Configurable settings via environment variables

## Prerequisites

- Docker Engine installed
- Docker Compose installed
- Sufficient disk space for media and data volumes
- Network ports available for service access

## Quick Start

Each subdirectory contains a `docker-compose.yaml` file that can be deployed with:

```bash
cd <service-directory>
docker-compose up -d
```

## Security Considerations

- Default passwords should be changed in production
- Consider using reverse proxy for external access
- Regularly update container images for security patches
- Review volume mount permissions

## Port Assignments

- **Pi-hole**: 8081 (web interface), 53 (DNS)
- **Plex**: 32400 (web interface)
- **Uptime Kuma**: 3001 (web interface)
- **Lab Web**: 80 (configurable)

## Network Requirements

- Pi-hole requires UDP/TCP 53 for DNS functionality
- Plex may require additional ports for remote access
- All web interfaces accessible via HTTP on specified ports