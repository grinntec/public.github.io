# Uptime Kuma Monitoring

Docker configuration for Uptime Kuma, a self-hosted monitoring tool for tracking service availability and performance.

## Overview

Uptime Kuma is a modern, open-source monitoring solution that provides real-time monitoring of websites, APIs, servers, and other services. It features a clean web interface and supports multiple notification channels.

## Features

- **Multi-Protocol Monitoring** - HTTP(s), TCP, Ping, DNS, and more
- **Real-time Dashboard** - Live status updates and response times
- **Status Pages** - Public status pages for your services
- **Notification Channels** - Email, Slack, Discord, Telegram, and 50+ others
- **Incident Management** - Automatic incident creation and resolution
- **Certificate Monitoring** - SSL certificate expiration tracking
- **API Access** - REST API for external integrations

## Configuration Details

### Port Mapping
- **3001:3001** - Web interface access

### Volume Mounts
- **/opt/uptime-kuma:/app/data** - Persistent data storage
- **/var/run/docker.sock:/var/run/docker.sock** - Docker monitoring capability

### Container Settings
- **restart: always** - Automatic restart on failure
- **Latest image** - Always uses the most recent version

## Quick Start

1. **Create Data Directory**:
   ```bash
   sudo mkdir -p /opt/uptime-kuma
   sudo chown 1000:1000 /opt/uptime-kuma
   ```

2. **Deploy Uptime Kuma**:
   ```bash
   docker-compose up -d
   ```

3. **Access Web Interface**:
   - URL: `http://<your-server-ip>:3001`
   - Create admin account on first visit

## Initial Configuration

### First-Time Setup
1. **Create Admin Account** - Set username and password
2. **Configure Notifications** - Add notification channels
3. **Add Monitors** - Start monitoring your services
4. **Create Status Page** - Optional public status page

### Adding Monitors

#### HTTP/HTTPS Monitoring
- **URL**: Service endpoint to monitor
- **Method**: GET, POST, etc.
- **Headers**: Custom HTTP headers
- **Body**: Request body for POST requests
- **Expected Status**: HTTP status codes (200, 301, etc.)
- **Keywords**: Text to search for in response

#### TCP Port Monitoring
- **Hostname**: Server hostname or IP
- **Port**: TCP port number
- **Timeout**: Connection timeout

#### Ping Monitoring
- **Hostname**: Server to ping
- **Packet Count**: Number of ping packets
- **Timeout**: Ping timeout

## Notification Channels

### Popular Integrations
- **Email** - SMTP server configuration
- **Slack** - Webhook URL integration
- **Discord** - Webhook notifications
- **Telegram** - Bot token and chat ID
- **Microsoft Teams** - Webhook connector
- **PagerDuty** - Incident management
- **Webhooks** - Custom HTTP notifications

### Setting Up Notifications
1. Go to **Settings → Notifications**
2. Click **Add New Notification**
3. Choose notification type
4. Configure connection details
5. Test notification
6. Assign to monitors

## Status Pages

### Creating Public Status Pages
1. Go to **Status Pages**
2. Click **New Status Page**
3. Configure page settings:
   - **Title**: Your status page name
   - **Description**: Page description
   - **Domain**: Custom domain (optional)
   - **Theme**: Light/dark theme
4. Add monitors to display
5. Customize appearance

### Status Page Features
- **Real-time Updates** - Live monitor status
- **Incident Timeline** - Historical incidents
- **Maintenance Windows** - Scheduled maintenance
- **Custom Branding** - Logo and colors
- **Multiple Languages** - Internationalization support

## Docker Integration

### Monitoring Docker Containers
With Docker socket access, Uptime Kuma can:
- Monitor container health
- Track container status
- Alert on container failures
- Integrate with Docker Compose services

### Security Considerations
Docker socket access provides significant privileges:
- **Read-only access** - Consider using read-only socket
- **Network isolation** - Limit container network access
- **Regular updates** - Keep container image updated

## Advanced Configuration

### Environment Variables
```yaml
environment:
  - UPTIME_KUMA_PORT=3001
  - UPTIME_KUMA_HOST=0.0.0.0
  - NODE_ENV=production
```

### Reverse Proxy Setup
For SSL and domain access:
```nginx
server {
    listen 443 ssl;
    server_name status.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Maintenance and Monitoring

### Regular Tasks
```bash
# View logs
docker-compose logs -f uptime-kuma

# Update container
docker-compose pull && docker-compose up -d

# Backup data
tar -czf uptime-kuma-backup.tar.gz /opt/uptime-kuma

# Monitor resource usage
docker stats uptime-kuma
```

### Performance Optimization
- **Monitor Intervals** - Balance frequency vs. resource usage
- **Database Cleanup** - Regular data retention policies
- **Resource Limits** - Set CPU/memory limits if needed

## Troubleshooting

### Common Issues
- **Port Conflicts** - Change port if 3001 is in use
- **Permission Errors** - Check data directory ownership
- **Notification Failures** - Verify webhook URLs and credentials
- **High CPU Usage** - Reduce monitor frequency or count

### Useful Commands
```bash
# Check container status
docker-compose ps

# Restart service
docker-compose restart uptime-kuma

# View configuration
docker inspect uptime-kuma

# Access container shell
docker exec -it uptime-kuma /bin/bash
```

## Integration Examples

### Monitoring Stack
- **Uptime Kuma** - Service availability
- **Grafana** - Metrics visualization  
- **Prometheus** - Metrics collection
- **Alertmanager** - Alert routing

### Common Monitors
- **Web Applications** - HTTP/HTTPS endpoints
- **APIs** - REST API availability
- **Databases** - TCP port monitoring
- **Network Services** - DNS, SMTP, etc.
- **Infrastructure** - Server ping monitoring