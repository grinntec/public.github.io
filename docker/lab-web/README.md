# Lab Web Application

A simple Docker-based web application for testing and learning Docker containerization concepts.

## Overview

This is a basic web application that serves a static HTML page with dynamic content display. It's designed as a learning tool for Docker fundamentals and container deployment.

## Contents

- **Dockerfile** - Container build configuration using Nginx
- **src/** - Web application source files
  - `index.html` - Main web page
  - `style.css` - Styling for the page
  - `script.js` - JavaScript for dynamic content
  - `images/` - Static image assets

## Features

- **Dynamic Content Display**:
  - Current hostname of the container
  - Real-time clock display
  - Random number generation
- **Responsive Design** - Mobile-friendly layout
- **Docker Integration** - Shows container-specific information

## Technology Stack

- **Base Image**: nginx:latest
- **Web Server**: Nginx
- **Frontend**: HTML5, CSS3, JavaScript
- **Port**: 80 (HTTP)

## Building and Running

### Build the Image
```bash
docker build -t lab-web .
```

### Run the Container
```bash
docker run -d -p 8080:80 --name lab-web lab-web
```

### Using Docker Compose
```bash
docker-compose up -d
```

## Accessing the Application

Once running, access the web application at:
- Local: `http://localhost:8080`
- Network: `http://<docker-host-ip>:8080`

## Dockerfile Explanation

```dockerfile
FROM nginx:latest           # Use official Nginx image
LABEL maintainer="..."      # Set maintainer information
WORKDIR /usr/share/nginx/html  # Set working directory
COPY ./src .               # Copy source files to web root
EXPOSE 80                  # Expose HTTP port
CMD ["nginx", "-g", "daemon off;"]  # Start Nginx server
```

## Educational Use Cases

- **Container Basics** - Understanding Docker build and run processes
- **Volume Mounting** - Testing file system isolation
- **Port Mapping** - Learning network configuration
- **Multi-container** - Integration with other services
- **Load Balancing** - Multiple instance deployment

## Customization

- Modify `src/index.html` to change page content
- Update `src/style.css` for different styling
- Edit `src/script.js` to add new dynamic features
- Replace images in `src/images/` for custom branding

## Development Workflow

1. Make changes to files in `src/` directory
2. Rebuild the Docker image
3. Stop and remove existing container
4. Run new container with updated image
5. Test changes in browser