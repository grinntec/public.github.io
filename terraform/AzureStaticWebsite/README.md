# Azure Static Website

Terraform configuration for deploying static websites on Azure using Azure Static Web Apps.

## Overview

This Terraform project creates the necessary Azure infrastructure to host static websites, including resource groups and Azure Static Web Apps service. It's designed to be environment-aware and follows infrastructure as code best practices.

## Architecture

The configuration deploys:
- **Azure Resource Group** - Container for all website resources
- **Azure Static Web App** - Hosting service for static content
- **Environment-specific naming** - Resources named based on environment and prefix

## Prerequisites

### Required Tools
- Terraform >= 1.1.0
- Azure CLI
- Git repository with static website content

### Azure Authentication
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"
```

## Configuration

### Variables
The project uses several variables for customization:

#### Required Variables
- **prefix** - Application identifier for resource naming
- **environment** - Environment name (dev, staging, prod)
- **resource_group_location** - Azure region for deployment

#### Example terraform.tfvars
```hcl
prefix                   = "myapp"
environment             = "dev"
resource_group_location = "West Europe"
```

### Resource Naming Convention
Resources follow the pattern:
- Resource Group: `rg-{prefix}-{environment}`
- Static Web App: `swa-{prefix}-{environment}`

## Deployment

### Initialize and Deploy
```bash
# Navigate to terraform directory
cd terraform/

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply configuration
terraform apply -var-file="terraform.tfvars"
```

### Environment-Specific Deployment
```bash
# Development
terraform apply -var-file="dev.tfvars"

# Staging
terraform apply -var-file="staging.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

## File Structure

```
AzureStaticWebsite/
├── terraform/
│   ├── azurerm_resource_group.tf    # Resource group configuration
│   ├── azurerm_static_site.tf       # Static Web App configuration
│   ├── variables.tf                 # Variable definitions (if exists)
│   ├── outputs.tf                   # Output definitions (if exists)
│   └── providers.tf                 # Provider configuration (if exists)
├── terraform.tfvars                 # Variable values
└── README.md                        # This file
```

## Azure Static Web Apps Features

### Deployment Options
- **GitHub Integration** - Automatic deployments from GitHub repositories
- **Azure DevOps** - CI/CD pipeline integration
- **Manual Upload** - Direct file upload via Azure CLI

### Built-in Features
- **Global CDN** - Worldwide content distribution
- **Custom Domains** - HTTPS-enabled custom domain support
- **Authentication** - Built-in authentication providers
- **API Integration** - Azure Functions backend integration
- **Staging Environments** - Pull request preview deployments

## Configuration Examples

### Basic Static Site
```hcl
resource "azurerm_static_site" "example" {
  name                = "swa-${var.prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location           = azurerm_resource_group.this.location
  
  tags = local.tags
}
```

### With GitHub Integration
```hcl
resource "azurerm_static_site" "example" {
  name                = "swa-${var.prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location           = azurerm_resource_group.this.location
  
  sku_tier = "Standard"
  sku_size = "Standard"
  
  tags = local.tags
}
```

## Post-Deployment Setup

### Configure GitHub Repository
1. Connect repository to Static Web App
2. Configure build settings
3. Set up automated deployments

### Custom Domain Setup
```bash
# Add custom domain
az staticwebapp hostname set \
  --name "swa-myapp-prod" \
  --resource-group "rg-myapp-prod" \
  --hostname "www.example.com"
```

### Authentication Configuration
```json
{
  "auth": {
    "identityProviders": {
      "github": {
        "registration": {
          "clientIdSettingName": "GITHUB_CLIENT_ID",
          "clientSecretSettingName": "GITHUB_CLIENT_SECRET"
        }
      }
    }
  }
}
```

## Outputs

The configuration may provide outputs such as:
- **static_web_app_url** - Default URL of the static web app
- **static_web_app_id** - Resource ID for integration
- **resource_group_name** - Created resource group name

## Cost Optimization

### SKU Selection
- **Free Tier** - Limited bandwidth and storage
- **Standard Tier** - Production workloads with custom domains

### Monitoring Usage
```bash
# Check Static Web App metrics
az monitor metrics list \
  --resource "/subscriptions/.../staticSites/swa-myapp-prod" \
  --metric "Requests"
```

## Troubleshooting

### Common Issues
- **Deployment failures** - Check build configuration
- **Custom domain issues** - Verify DNS configuration
- **Authentication problems** - Check provider settings

### Useful Commands
```bash
# View Static Web App details
az staticwebapp show \
  --name "swa-myapp-prod" \
  --resource-group "rg-myapp-prod"

# List deployment history
az staticwebapp environment list \
  --name "swa-myapp-prod" \
  --resource-group "rg-myapp-prod"

# View logs
az staticwebapp logs \
  --name "swa-myapp-prod" \
  --resource-group "rg-myapp-prod"
```

## Security Best Practices

- Enable HTTPS for all custom domains
- Implement proper authentication where needed
- Use environment variables for sensitive configuration
- Regular security updates for dependencies
- Monitor access logs and usage patterns

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Deploy Static Site
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build and Deploy
      uses: Azure/static-web-apps-deploy@v1
      with:
        azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
        repo_token: ${{ secrets.GITHUB_TOKEN }}
        action: "upload"
        app_location: "/"
        output_location: "dist"
```