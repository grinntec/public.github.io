# Image Management

Container image management utilities for Kubernetes environments.

## File: transfer-images-between-registries.yaml

### Purpose
This PowerShell script facilitates the transfer of Docker images from a source registry to a destination Azure Container Registry (ACR). It automates the process of pulling, retagging, and pushing container images between registries.

### Features
- **Multi-Registry Support** - Transfer between any Docker-compatible registries
- **Azure ACR Integration** - Specialized support for Azure Container Registry
- **Batch Processing** - Transfer multiple images in a single operation
- **Interactive Confirmation** - Optional user confirmation before pushing images
- **Comprehensive Logging** - Detailed logging of all transfer operations
- **Error Handling** - Robust error handling and recovery

### Supported Images
The script includes a predefined list of common container images:
- `bash:5.2.26` - Shell environment
- `fluent-bit:1.9.6` - Log processing
- `fuse-deployment:0.11` - FUSE filesystem support
- `fuse-job:0.11` - FUSE job processing
- `nvidia/k8s-device-plugin:v0.12.2` - NVIDIA GPU support
- `oauth2-proxy:v7.6.1-nc` - Authentication proxy
- `postgres:10.23-alpine3.16` - PostgreSQL database
- `traefik:v2.1` - Load balancer and reverse proxy

### Prerequisites
- **Azure CLI** - Installed and authenticated
- **Docker** - Docker Engine running
- **PowerShell** - PowerShell 5.1 or later
- **Registry Access** - Authentication to both source and destination registries

### Usage

#### Basic Usage
```powershell
# Run with default registries
.\transfer-images-between-registries.ps1

# Specify custom registries
.\transfer-images-between-registries.ps1 -sourceRegistry "my-source.io" -destinationRegistry "my-dest.azurecr.io"
```

#### Parameters
- **sourceRegistry** - Source Docker registry URL (default: "source-registry.io")
- **destinationRegistry** - Destination ACR URL (default: "destination-registry.azurecr.io")

### Workflow Process

1. **Authentication** - Login to both source and destination registries
2. **Image Pulling** - Pull each image from the source registry
3. **Image Tagging** - Retag images for the destination registry
4. **User Confirmation** - Optional confirmation before pushing
5. **Image Pushing** - Push images to destination registry
6. **Cleanup** - Remove temporary local images (optional)

### Use Cases

#### Air-Gapped Environments
Transfer images to private registries for isolated environments:
```powershell
.\transfer-images.ps1 -sourceRegistry "docker.io" -destinationRegistry "private.registry.local"
```

#### Cloud Migration
Move images between cloud providers:
```powershell
.\transfer-images.ps1 -sourceRegistry "gcr.io/project" -destinationRegistry "myregistry.azurecr.io"
```

#### Compliance and Security
Copy approved images to compliant registries:
```powershell
.\transfer-images.ps1 -sourceRegistry "public.registry" -destinationRegistry "compliance.azurecr.io"
```

### Authentication

#### Azure Container Registry
```bash
# Login to ACR
az acr login --name myregistry

# Alternative: Docker login
docker login myregistry.azurecr.io
```

#### Other Registries
```bash
# Docker Hub
docker login

# Custom registry
docker login my-registry.com
```

### Customization

#### Adding Custom Images
Modify the images array in the script:
```powershell
$images = @(
    "nginx:latest",
    "redis:7-alpine",
    "mysql:8.0",
    "your-custom-app:v1.0.0"
)
```

#### Registry-Specific Configuration
Add registry-specific logic:
```powershell
if ($destinationRegistry -like "*.azurecr.io") {
    # Azure-specific configuration
    az acr login --name $registryName
}
```

### Error Handling and Troubleshooting

#### Common Issues
- **Authentication Failures** - Verify registry credentials
- **Network Connectivity** - Check firewall and proxy settings
- **Storage Space** - Ensure sufficient disk space for image pulls
- **Image Not Found** - Verify image names and tags exist

#### Debug Commands
```powershell
# Check Docker daemon
docker version

# Verify registry authentication
docker login $registry

# Test image pull
docker pull $sourceRegistry/$imageName

# Check available disk space
Get-WmiObject -Class Win32_LogicalDisk
```

### Performance Optimization

#### Parallel Processing
Modify script for concurrent transfers:
```powershell
$images | ForEach-Object -Parallel {
    # Transfer logic here
} -ThrottleLimit 5
```

#### Image Layer Caching
Leverage Docker's layer caching:
```powershell
# Keep common base layers
docker pull ubuntu:latest
docker pull alpine:latest
```

### Security Considerations

- **Credential Management** - Use secure credential storage
- **Image Scanning** - Scan images for vulnerabilities before transfer
- **Access Control** - Implement proper RBAC for registries
- **Audit Logging** - Maintain transfer audit logs
- **Network Security** - Use private networks where possible

### Integration with Kubernetes

#### Update Deployments
After image transfer, update Kubernetes deployments:
```bash
# Update deployment image
kubectl set image deployment/app container=$destinationRegistry/app:v1.0

# Apply new manifests
kubectl apply -f updated-manifests.yaml
```

#### ImagePullSecrets
Configure registry credentials:
```bash
# Create registry secret
kubectl create secret docker-registry acr-secret \
  --docker-server=$destinationRegistry \
  --docker-username=$username \
  --docker-password=$password

# Use in deployment
kubectl patch deployment app -p '{"spec":{"template":{"spec":{"imagePullSecrets":[{"name":"acr-secret"}]}}}}'
```