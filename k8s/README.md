# Kubernetes (k8s) Resources

This directory contains Kubernetes manifests and configurations for various cluster management tasks.

## Directory Structure

- **dns/** - CoreDNS customization and DNS configuration
- **images/** - Container image management and transfer utilities
- **pods/** - Support and troubleshooting pod definitions

## Overview

These Kubernetes resources provide:
- **DNS Customization** - Custom DNS entries and CoreDNS configuration
- **Image Management** - Tools for transferring images between registries
- **Support Tools** - Troubleshooting and debugging pods for cluster maintenance

## Prerequisites

- Kubernetes cluster access
- kubectl configured and authenticated
- Appropriate RBAC permissions for resource creation
- Container registry access (for image operations)

## Common Usage Patterns

### Applying Manifests
```bash
# Apply individual manifests
kubectl apply -f <manifest-file>.yaml

# Apply all manifests in a directory
kubectl apply -f <directory>/

# Apply with specific namespace
kubectl apply -f <manifest-file>.yaml -n <namespace>
```

### Monitoring Resources
```bash
# Check resource status
kubectl get pods,services,configmaps

# View resource details
kubectl describe <resource-type> <resource-name>

# View logs
kubectl logs <pod-name>
```

## Security Considerations

- **RBAC Permissions** - Ensure minimal required permissions
- **Network Policies** - Implement appropriate network isolation
- **Resource Limits** - Set CPU/memory limits where applicable
- **Image Security** - Use trusted container images and scan for vulnerabilities

## Best Practices

- **Namespace Organization** - Use appropriate namespaces for isolation
- **Resource Naming** - Follow consistent naming conventions
- **Labels and Annotations** - Use metadata for resource organization
- **Documentation** - Include comments in YAML files for clarity
- **Version Control** - Track changes to manifests in git

## Troubleshooting

Common commands for debugging Kubernetes resources:

```bash
# Check cluster status
kubectl cluster-info

# View events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug pod issues
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous

# Check resource quotas
kubectl describe quota
kubectl describe limitrange
```