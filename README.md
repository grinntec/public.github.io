# GRINNTEC | public.github.io

Welcome to the **public.github.io** repository! 🎉 This is a comprehensive collection of infrastructure code, automation tools, and deployment resources for cloud-native applications and DevOps workflows.

## About

This repository serves as the source for public-facing infrastructure code and automation tools. It is part of the larger ecosystem of **[Grinntec](https://www.grinntec.net)**, providing practical examples and reusable components for modern cloud infrastructure management.

## Repository Structure

### 🐳 [Docker](./docker/)
Containerized applications and services
- **lab-web** - Simple web application for Docker learning
- **pi-hole-server** - DNS ad-blocker server configuration  
- **plex-server** - Media streaming server setup
- **uptime-kuma** - Uptime monitoring and status pages

### ☁️ [Azure](./azure/)
Azure cloud automation and management tools
- **automation-account** - Runbooks for resource lifecycle management
- **policy** - Azure Policy definitions for governance
- **powershell** - Reusable PowerShell functions for Azure operations

### 🚀 [GitHub Actions](./github-actions/)
CI/CD workflows and custom actions
- **terraform-to-azure-cicd** - Comprehensive Terraform deployment pipelines

### ☸️ [Kubernetes (k8s)](./k8s/)
Kubernetes manifests and cluster management
- **dns** - CoreDNS customization and DNS configuration
- **images** - Container image management utilities
- **pods** - Support and troubleshooting pod definitions

### 🏗️ [Terraform](./terraform/)
Infrastructure as Code for Azure deployments
- **AzureNetworkSecurityGroup** - NSG management with CSV rule definition
- **AzureStaticWebsite** - Static website hosting infrastructure
- **CreateAzureLinuxVm** - Virtual machine deployment templates
- **HowModulesWork** - Terraform modules examples and patterns

### 🐍 [Python](./python/)
Python utilities and applications
- **git-helper** - Git repository management automation tool

### 📊 [Streamlit](./streamlit/)
Interactive web applications and dashboards
- **basic-webpage** - Simple Streamlit application with animations

## Key Features

### 🔄 Automation & CI/CD
- **GitHub Actions workflows** for automated deployments
- **Azure Automation Account** runbooks for resource management
- **Terraform pipelines** with security scanning and cost estimation

### 🛡️ Security & Governance
- **Azure Policy** enforcement for compliance
- **Security scanning** integrated into CI/CD pipelines
- **Key Vault integration** for secrets management
- **RBAC and least privilege** access patterns

### 📦 Containerization
- **Docker Compose** configurations for easy deployment
- **Kubernetes manifests** for orchestrated environments
- **Container registry** management utilities

### 🏭 Infrastructure as Code
- **Terraform modules** for reusable infrastructure components
- **Environment-specific** configurations
- **State management** best practices
- **Cost optimization** strategies

## Getting Started

### Prerequisites
- **Git** - Version control
- **Docker** - Container runtime
- **Azure CLI** - Azure authentication and management
- **Terraform** - Infrastructure as Code tool
- **kubectl** - Kubernetes command-line tool (for k8s resources)

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/grinntec/public.github.io.git
cd public.github.io

# Choose your area of interest
cd docker/lab-web          # For Docker examples
cd terraform/              # For infrastructure code
cd azure/automation-account # For Azure automation
cd k8s/                    # For Kubernetes resources
```

### Azure Authentication
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"
```

## Usage Examples

### Deploy a Docker Service
```bash
cd docker/uptime-kuma
docker-compose up -d
```

### Deploy Infrastructure with Terraform
```bash
cd terraform/AzureStaticWebsite/terraform
terraform init
terraform plan
terraform apply
```

### Run Azure Automation Scripts
```bash
cd azure/automation-account/AutomaticResourceDelete
# Configure as Azure Automation runbook
```

### Apply Kubernetes Manifests
```bash
cd k8s/pods
kubectl apply -f support-pod-node.yaml
```

## Project Highlights

### 🎯 Production-Ready Patterns
- **Multi-environment support** with consistent naming conventions
- **Automated testing and validation** in CI/CD pipelines
- **Security-first approach** with secrets management and scanning
- **Cost optimization** with resource lifecycle management

### 📚 Educational Resources
- **Comprehensive documentation** for each component
- **Step-by-step tutorials** and examples
- **Best practices** and design patterns
- **Troubleshooting guides** and common solutions

### 🔧 Enterprise Features
- **Monitoring and alerting** with Uptime Kuma and Azure Monitor
- **Log aggregation** with structured logging
- **Backup and disaster recovery** strategies
- **Compliance and governance** through Azure Policy

## Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes with appropriate documentation
4. Test thoroughly in a development environment
5. Submit a pull request with detailed description

### Code Standards
- **Clear documentation** for all components
- **Security best practices** implementation
- **Infrastructure as Code** principles
- **Consistent naming conventions** across resources

## Support and Documentation

### Additional Resources
- **[Grinntec Website](https://www.grinntec.net)** - Detailed tutorials and guides
- **[GitHub Discussions](https://github.com/grinntec/public.github.io/discussions)** - Community support
- **Individual README files** - Component-specific documentation

### Getting Help
- Check the README files in each directory for specific guidance
- Review the comprehensive documentation on the Grinntec website
- Open an issue for bugs or feature requests
- Start a discussion for general questions

## License

This project is licensed under the terms specified in the [LICENSE](./LICENSE) file.

---

**Happy Building!** 🚀

*This repository represents a practical approach to modern DevOps and cloud infrastructure management, providing reusable components and patterns for real-world deployments.*