# DNS Configuration

CoreDNS customization and DNS configuration for Kubernetes clusters.

## File: coredns-custom.yaml

### Purpose
This ConfigMap allows customization of CoreDNS behavior in a Kubernetes cluster by defining static DNS entries and custom DNS resolution rules.

### Features
- **Static DNS Entries** - Map IP addresses to specific domain names
- **Fallthrough Support** - Allow unresolved queries to continue to other DNS plugins
- **Cluster-wide DNS** - Affects all pods in the cluster
- **Custom Domain Resolution** - Override default DNS behavior for specific domains

### Configuration Details

**ConfigMap Information:**
- **Name**: `coredns-custom`
- **Namespace**: `kube-system`
- **Purpose**: Override default CoreDNS configuration

**Custom DNS Entries:**
The configuration uses the `hosts` plugin to define static mappings:
```yaml
hosts {
  10.0.0.115 appname.domain.net
  fallthrough
}
```

### How It Works

1. **Static Resolution** - Queries for configured domains return predefined IP addresses
2. **Fallthrough Behavior** - Unmatched queries pass to the next DNS plugin
3. **Priority Handling** - Custom entries take precedence over external DNS
4. **Cluster Integration** - All pods inherit these DNS settings

### Use Cases

- **Internal Service Discovery** - Map internal services to friendly names
- **Development Environments** - Override production domains for testing
- **Legacy System Integration** - Bridge old systems with new DNS names
- **Load Balancer Aliases** - Create multiple names for the same service
- **Split-Brain DNS** - Different resolution for internal vs external access

### Deployment

```bash
# Apply the ConfigMap
kubectl apply -f coredns-custom.yaml

# Restart CoreDNS to pick up changes
kubectl rollout restart deployment/coredns -n kube-system

# Verify deployment
kubectl get configmap coredns-custom -n kube-system
```

### Configuration Examples

#### Multiple Static Entries
```yaml
data:
  custom.override: |
    hosts {
      10.0.0.115 app1.internal.com
      10.0.0.116 app2.internal.com
      10.0.0.117 db.internal.com
      fallthrough
    }
```

#### Development Environment Override
```yaml
data:
  dev.override: |
    hosts {
      192.168.1.100 api.production.com
      192.168.1.101 web.production.com
      fallthrough
    }
```

#### Load Balancer Aliases
```yaml
data:
  aliases.override: |
    hosts {
      10.0.0.200 app.example.com
      10.0.0.200 www.example.com
      10.0.0.200 api.example.com
      fallthrough
    }
```

### Verification and Testing

#### Test DNS Resolution
```bash
# Create a test pod
kubectl run dns-test --image=busybox --rm -it -- /bin/sh

# Inside the pod, test DNS resolution
nslookup appname.domain.net
dig appname.domain.net
```

#### Check CoreDNS Logs
```bash
# View CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Follow logs in real-time
kubectl logs -n kube-system -l k8s-app=kube-dns -f
```

### Advanced Configuration

#### Custom Upstream DNS
```yaml
data:
  upstream.override: |
    hosts {
      10.0.0.115 appname.domain.net
      fallthrough
    }
    forward . 8.8.8.8 8.8.4.4
```

#### Conditional Forwarding
```yaml
data:
  conditional.override: |
    hosts {
      10.0.0.115 appname.domain.net
      fallthrough
    }
    forward company.internal 10.0.0.1
```

### Troubleshooting

#### Common Issues
- **Changes Not Applied** - Restart CoreDNS deployment
- **Syntax Errors** - Validate YAML formatting
- **Permission Denied** - Check RBAC permissions for kube-system namespace
- **DNS Not Resolving** - Verify IP addresses are reachable

#### Debugging Commands
```bash
# Check ConfigMap content
kubectl get configmap coredns-custom -n kube-system -o yaml

# Verify CoreDNS configuration
kubectl get configmap coredns -n kube-system -o yaml

# Check CoreDNS pod status
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test from specific node
kubectl debug node/<node-name> -it --image=busybox
```

### Security Considerations

- **DNS Spoofing** - Only trusted administrators should modify DNS settings
- **Network Isolation** - Ensure internal IPs are not exposed externally
- **Access Control** - Limit access to kube-system namespace
- **Audit Logging** - Monitor changes to DNS configuration

### Best Practices

- **Documentation** - Comment your DNS entries with purpose
- **Naming Convention** - Use consistent domain naming patterns
- **Testing** - Verify DNS changes before production deployment
- **Backup** - Keep backups of original CoreDNS configuration
- **Monitoring** - Set up alerts for DNS resolution failures