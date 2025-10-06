# Plex Media Server

Docker configuration for deploying Plex Media Server to stream personal media content across devices.

## Overview

Plex Media Server organizes and streams your personal media collection (movies, TV shows, music, photos) to various devices. This configuration uses the LinuxServer.io Plex image for optimal performance and easy management.

## Features

- **Media Streaming** - Stream to phones, tablets, computers, smart TVs
- **Automatic Organization** - Automatically organizes and tags media
- **Remote Access** - Access your media from anywhere (with Plex Pass)
- **Transcoding** - Converts media formats for different devices
- **User Management** - Multiple user accounts with parental controls
- **Metadata Fetching** - Automatic movie/TV show information and artwork

## Configuration Details

### Network Configuration
- **network_mode: host** - Uses host networking for optimal performance
- **Web Interface**: `http://<your-ip>:32400/web`

### Environment Variables
- **PUID**: 1000 - User ID for file permissions
- **PGID**: 1000 - Group ID for file permissions  
- **TZ**: `Europe/Copenhagen` - Set your timezone
- **VERSION**: docker - Use the latest Docker version
- **PLEX_CLAIM**: Optional - For automatic server claiming

### Volume Mounts
- **Media Storage** - Mount your media directories
- **Configuration** - Persistent Plex settings and metadata

## Pre-Deployment Setup

### 1. Prepare Media Storage
Organize your media in a structure like:
```
/path/to/media/
├── Movies/
│   ├── Movie Name (Year)/
│   └── Movie Name (Year).mkv
├── TV Shows/
│   ├── Show Name/
│   │   ├── Season 01/
│   │   └── S01E01 - Episode Name.mkv
└── Music/
    ├── Artist/
    └── Album/
```

### 2. Update Docker Compose
```yaml
volumes:
  - /path/to/plex/config:/config
  - /path/to/media:/media-share
  - /path/to/transcode:/transcode  # Optional: SSD for transcoding
```

## Quick Start

1. **Update Configuration**:
   ```bash
   # Edit docker-compose.yaml with your media paths
   nano docker-compose.yaml
   ```

2. **Deploy Plex**:
   ```bash
   docker-compose up -d
   ```

3. **Initial Setup**:
   - Navigate to `http://<your-server-ip>:32400/web`
   - Sign in to your Plex account
   - Follow the setup wizard
   - Add your media libraries

## Plex Claim Token (Optional)

For automatic server setup:

1. Get claim token from https://plex.tv/claim
2. Add to PLEX_CLAIM environment variable
3. Token is valid for 4 minutes
4. Restart container after adding token

## Library Configuration

### Adding Libraries
1. **Movies**: Point to your Movies directory
2. **TV Shows**: Point to your TV Shows directory  
3. **Music**: Point to your Music directory
4. **Photos**: Point to your Photos directory

### Scanner Settings
- **Movie Scanner**: Plex Movie Scanner
- **TV Scanner**: Plex Series Scanner
- **Music Scanner**: Plex Music Scanner
- **Agent**: Choose metadata provider (TheMovieDB, TVDb, etc.)

## Performance Optimization

### Hardware Transcoding
For Intel/NVIDIA hardware acceleration:
```yaml
devices:
  - /dev/dri:/dev/dri  # Intel QuickSync
# or
runtime: nvidia  # NVIDIA GPU
```

### Storage Considerations
- **Metadata Storage** - Use SSD for /config directory
- **Transcoding** - Use SSD for temporary transcoding files
- **Media Storage** - Can use slower HDDs for media files

## Security and Access

### Remote Access
- **Plex Pass Required** - For official remote access
- **Port Forwarding** - Forward port 32400 on router
- **Alternative** - Use reverse proxy with SSL

### User Management
- **Server Owner** - Full administrative access
- **Managed Users** - Limited access, parental controls
- **Home Users** - Free alternative to Plex Pass sharing

## Maintenance

### Regular Tasks
```bash
# View logs
docker-compose logs -f plex

# Update container
docker-compose pull && docker-compose up -d

# Backup configuration
tar -czf plex-backup.tar.gz /path/to/plex/config

# Monitor resource usage
docker stats plex
```

### Library Maintenance
- **Scan Libraries** - Refresh to detect new media
- **Optimize Database** - Periodic database cleanup
- **Clean Bundles** - Remove orphaned metadata
- **Empty Trash** - Remove deleted items permanently

## Troubleshooting

### Common Issues
- **Permission Errors** - Check PUID/PGID match file ownership
- **Transcoding Issues** - Verify hardware acceleration setup
- **Remote Access** - Check port forwarding and network settings
- **Library Not Updating** - Manual scan or check file permissions

### Useful Commands
```bash
# Check container status
docker-compose ps

# Restart Plex
docker-compose restart plex

# View real-time logs
docker-compose logs -f plex

# Access container shell
docker exec -it plex /bin/bash
```

## Integration Options

- **Reverse Proxy** - Nginx/Traefik for SSL and domain access
- **Monitoring** - Tautulli for usage statistics
- **Request Management** - Overseerr/Ombi for media requests
- **Download Automation** - Sonarr/Radarr for automatic downloads