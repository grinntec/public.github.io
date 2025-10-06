# Support and Troubleshooting Pods

Kubernetes pod definitions for cluster troubleshooting and support tasks.

## Pod Definitions

### support-pod-node.yaml
A troubleshooting pod scheduled to a specific node for node-level debugging.

### support-pod-system.yaml  
A troubleshooting pod scheduled to system node pools for cluster-level debugging.

## Features

Both support pods include:
- **Ubuntu Base Image** - Latest Ubuntu with package management
- **Networking Tools** - Essential network debugging utilities
- **System Utilities** - Common system administration tools
- **Resource Limits** - Appropriate CPU and memory constraints
- **Long-running** - Infinite loop to keep containers available

### Installed Tools
- **netcat-openbsd** - Network testing and port scanning
- **telnet** - TCP connection testing
- **dnsutils** - DNS lookup and troubleshooting (dig, nslookup)
- **curl** - HTTP/HTTPS testing and API debugging
- **iputils-ping** - Network connectivity testing
- **git** - Version control and repository access

## Usage

### Deploy Support Pods
```bash
# Deploy node-specific support pod
kubectl apply -f support-pod-node.yaml

# Deploy system node support pod
kubectl apply -f support-pod-system.yaml

# Verify deployment
kubectl get pods -l app=support
```

### Access Support Pods
```bash
# Access node support pod
kubectl exec -it support-pod-node -- /bin/bash

# Access system support pod
kubectl exec -it support-pod-system -- /bin/bash

# Run single commands
kubectl exec support-pod-node -- ping google.com
kubectl exec support-pod-system -- nslookup kubernetes.default
```

## Troubleshooting Scenarios

### Network Connectivity Testing
```bash
# Test external connectivity
kubectl exec -it support-pod-node -- ping 8.8.8.8
kubectl exec -it support-pod-node -- curl -I https://google.com

# Test internal service connectivity
kubectl exec -it support-pod-node -- ping service-name.namespace.svc.cluster.local
kubectl exec -it support-pod-node -- telnet service-name 80
```

### DNS Resolution Testing
```bash
# Test DNS resolution
kubectl exec -it support-pod-node -- nslookup kubernetes.default
kubectl exec -it support-pod-node -- dig @10.0.0.10 example.com

# Test service discovery
kubectl exec -it support-pod-node -- nslookup service-name.namespace.svc.cluster.local
```

### Port and Service Testing
```bash
# Test port connectivity
kubectl exec -it support-pod-node -- nc -zv service-name 80
kubectl exec -it support-pod-node -- telnet service-ip 443

# Test HTTP services
kubectl exec -it support-pod-node -- curl -v http://service-name/health
```

### Cluster Resource Investigation
```bash
# Check environment variables
kubectl exec -it support-pod-system -- env | grep KUBERNETES

# Investigate mounted secrets/configmaps
kubectl exec -it support-pod-system -- ls -la /var/run/secrets/

# Check cluster communication
kubectl exec -it support-pod-system -- curl -k https://kubernetes.default/api/v1/namespaces
```

## Configuration Details

### support-pod-node.yaml
- **Scheduling**: Pinned to specific node (`aks-nodename-13402868-vmss000003`)
- **Purpose**: Node-specific debugging and testing
- **Namespace**: default
- **Resources**: 100m CPU request, 200m CPU limit, 128Mi-256Mi memory

### support-pod-system.yaml
- **Scheduling**: System node pool via nodeSelector (`mode: system`)
- **Purpose**: System-level cluster debugging
- **Tolerations**: Can run on system nodes with taints
- **Resources**: Same as node pod (100m-200m CPU, 128Mi-256Mi memory)

## Customization

### Modify Node Assignment
```yaml
# For specific node
spec:
  nodeName: your-node-name

# For node pool
spec:
  nodeSelector:
    nodepool: your-pool-name

# For node with taints
spec:
  tolerations:
  - key: "your-taint-key"
    operator: "Equal"
    value: "your-taint-value"
    effect: "NoSchedule"
```

### Add Additional Tools
```yaml
command:
  - "/bin/bash"
  - "-c"
  - |
    apt-get update && \
    apt-get install -y netcat-openbsd telnet dnsutils curl iputils-ping git \
    jq htop tcpdump strace && \
    while true; do sleep 3600; done
```

### Custom Image with Tools
Create a custom image with pre-installed tools:
```dockerfile
FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y netcat-openbsd telnet dnsutils curl iputils-ping git \
    jq htop tcpdump strace vim nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
CMD ["sleep", "infinity"]
```

## Security Considerations

### Pod Security
- **Minimal Privileges** - Run with least required permissions
- **Resource Limits** - Prevent resource exhaustion
- **Network Policies** - Limit network access if needed
- **Temporary Usage** - Remove when troubleshooting is complete

### Best Practices
```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
  - name: support-pod
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      capabilities:
        drop:
        - ALL
```

## Advanced Troubleshooting

### Network Policy Testing
```bash
# Test network policies
kubectl exec -it support-pod-node -- nc -zv denied-service 80
kubectl exec -it support-pod-node -- curl -m 5 http://blocked-service
```

### Storage and Volume Testing
```bash
# Mount test volumes
kubectl exec -it support-pod-node -- df -h
kubectl exec -it support-pod-node -- ls -la /mnt/volumes/
```

### Performance Testing
```bash
# CPU and memory stress testing
kubectl exec -it support-pod-node -- stress-ng --cpu 1 --timeout 30s
kubectl exec -it support-pod-node -- stress-ng --vm 1 --vm-bytes 100M --timeout 30s
```

## Cleanup

### Remove Support Pods
```bash
# Delete specific pods
kubectl delete pod support-pod-node
kubectl delete pod support-pod-system

# Delete using file
kubectl delete -f support-pod-node.yaml
kubectl delete -f support-pod-system.yaml

# Delete all support pods
kubectl delete pods -l purpose=troubleshooting
```

## Integration with Monitoring

### Log Collection
```bash
# View pod logs
kubectl logs support-pod-node
kubectl logs support-pod-system --follow

# Export logs
kubectl logs support-pod-node > troubleshooting-logs.txt
```

### Metrics and Monitoring
```bash
# Check resource usage
kubectl top pod support-pod-node
kubectl describe pod support-pod-node

# Monitor in real-time
watch kubectl get pods
```