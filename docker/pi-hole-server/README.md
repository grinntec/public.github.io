# Pi-hole DNS Server

Docker configuration for deploying Pi-hole, a network-wide ad blocker that acts as a DNS sinkhole.

## Overview

Pi-hole blocks ads and trackers at the DNS level, providing network-wide protection for all devices connected to your network. This configuration deploys Pi-hole in a Docker container with persistent storage.

## Features

- **Network-wide Ad Blocking** - Blocks ads for all devices on the network
- **DNS Server** - Acts as a recursive DNS resolver
- **Web Interface** - Browser-based administration dashboard
- **DHCP Server** - Optional DHCP functionality (commented out)
- **Custom Block Lists** - Configurable domain blocking
- **Query Logging** - Detailed DNS query monitoring

## Configuration Details

### Port Mappings
- **53:53/tcp & 53:53/udp** - DNS service
- **67:67/udp** - DHCP server (if enabled)
- **8081:80/tcp** - Web interface (mapped to avoid conflicts)

### Environment Variables
- **TZ**: `Europe/Copenhagen` - Set your timezone
- **WEBPASSWORD**: `jU3cZrEBmzbe` - **⚠️ Change this password!**
- **PIHOLE_DNS_**: `8.8.8.8;8.8.4.4` - Upstream DNS servers

### Persistent Storage
- **./etc-pihole** - Pi-hole configuration and settings
- **./etc-dnsmasq.d** - DNS configuration files

## Quick Start

1. **Update Configuration**:
   ```bash
   # Edit docker-compose.yaml and change the WEBPASSWORD
   nano docker-compose.yaml
   ```

2. **Deploy Pi-hole**:
   ```bash
   docker-compose up -d
   ```

3. **Access Web Interface**:
   - URL: `http://<your-server-ip>:8081/admin`
   - Password: Use the password you set in WEBPASSWORD

## Post-Deployment Configuration

### Configure Network Devices
Point your devices' DNS settings to the Pi-hole server IP address:
- **Router DHCP**: Set Pi-hole IP as primary DNS
- **Individual Devices**: Manually set DNS to Pi-hole IP
- **DHCP Option**: Enable Pi-hole DHCP if desired

### Web Interface Features
- **Dashboard** - Overview of blocking statistics
- **Query Log** - Real-time DNS query monitoring  
- **Whitelist/Blacklist** - Custom domain management
- **Settings** - DNS and blocking configuration
- **Tools** - Network diagnostics and utilities

## Security Considerations

- **Change Default Password** - Update WEBPASSWORD immediately
- **Network Access** - Restrict access to trusted networks
- **Updates** - Regularly update the container image
- **Backup Configuration** - Backup ./etc-pihole directory

## DHCP Server Setup (Optional)

To use Pi-hole as your DHCP server:

1. Uncomment the network_mode: "host" line
2. Remove the ports section
3. Add NET_ADMIN capability (already included)
4. Disable DHCP on your existing router
5. Configure DHCP settings in Pi-hole web interface

## Troubleshooting

### Common Issues
- **Port 53 in use**: Stop systemd-resolved or change ports
- **Permission denied**: Check volume mount permissions
- **Can't reach web interface**: Verify port mapping and firewall

### Useful Commands
```bash
# View logs
docker-compose logs -f pihole

# Restart container
docker-compose restart pihole

# Update container
docker-compose pull && docker-compose up -d

# Backup configuration
tar -czf pihole-backup.tar.gz ./etc-pihole ./etc-dnsmasq.d
```

## Integration with Other Services

- **Unbound** - Use as recursive DNS resolver
- **Cloudflared** - DNS over HTTPS upstream
- **Reverse Proxy** - Access via domain name
- **Monitoring** - Integration with Uptime Kuma or other monitoring tools

## Performance Tuning

- **Cache Size** - Adjust DNS cache settings
- **Block Lists** - Balance between blocking and performance  
- **Log Retention** - Configure log rotation
- **Resource Limits** - Set appropriate CPU/memory limits