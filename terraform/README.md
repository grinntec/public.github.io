# Terraform Infrastructure as Code

This directory contains Terraform configurations for deploying and managing cloud infrastructure, primarily focused on Microsoft Azure.

## Projects Overview

- **AzureNetworkSecurityGroup/** - Network Security Group management with CSV-based rule definition
- **AzureStaticWebsite/** - Static website hosting on Azure
- **CreateAzureLinuxVm/** - Basic Linux VM creation
- **CreateAzureLinuxVmKvShhKeys/** - Linux VM with Key Vault SSH key integration
- **HowModulesWork/** - Terraform modules demonstration and examples

## Prerequisites

### Required Tools
- **Terraform** - Version 1.1.0 or later
- **Azure CLI** - For authentication and Azure provider setup
- **Git** - For version control
- **Text Editor** - VS Code recommended with Terraform extension

### Azure Authentication
```bash
# Login to Azure
az login

# Set subscription (if multiple)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

## Common Terraform Workflow

### Basic Commands
```bash
# Initialize Terraform
terraform init

# Plan infrastructure changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Advanced Workflow
```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources in state
terraform state list
```

## Project Structure

### Standard Layout
```
terraform-project/
├── main.tf                # Main configuration
├── variables.tf           # Variable definitions
├── outputs.tf            # Output definitions
├── terraform.tfvars      # Variable values
├── providers.tf          # Provider configuration
├── versions.tf           # Version constraints
└── README.md             # Documentation
```

### Module Structure
```
modules/
├── module-name/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── examples/
    └── basic/
        ├── main.tf
        └── variables.tf
```

## Best Practices

### Code Organization
- Use consistent naming conventions
- Separate environments with workspaces or directories
- Implement proper module structure
- Use version pinning for providers and modules

### Security
- Store sensitive data in Azure Key Vault
- Use managed identities where possible
- Implement least privilege access
- Never commit secrets to version control

### State Management
```bash
# Use remote state for team collaboration
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name      = "tfstate"
    key                = "project.terraform.tfstate"
  }
}
```

## Azure Provider Configuration

### Basic Configuration
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Advanced Configuration
```hcl
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  
  # Optional: Use specific subscription
  subscription_id = var.subscription_id
}
```

## Common Resources

### Resource Groups
```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-example"
  location = "West Europe"
  
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### Virtual Networks
```hcl
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

## Environment Management

### Workspaces
```bash
# Create workspace
terraform workspace new development

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select production
```

### Variable Files
```bash
# Development
terraform apply -var-file="dev.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

## Module Development

### Creating Modules
1. Design module interface (variables and outputs)
2. Implement module logic
3. Add validation and documentation
4. Test with examples
5. Version and publish

### Using Modules
```hcl
module "virtual_machine" {
  source = "./modules/azure-vm"
  
  vm_name             = "web-server"
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  vm_size            = "Standard_B2s"
}
```

## Debugging and Troubleshooting

### Enable Debug Logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform apply
```

### Common Issues
- **Provider authentication** - Check Azure CLI login
- **Resource conflicts** - Verify resource names are unique
- **State issues** - Use terraform state commands
- **Permission errors** - Check Azure RBAC permissions

### Useful Commands
```bash
# Import existing resources
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/rg-name

# Remove resource from state
terraform state rm azurerm_resource_group.example

# Refresh state
terraform refresh
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Terraform
on: [push, pull_request]
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: hashicorp/setup-terraform@v1
    - run: terraform init
    - run: terraform plan
    - run: terraform apply -auto-approve
```

### Azure DevOps
```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: TerraformInstaller@0
  inputs:
    terraformVersion: 'latest'
- script: terraform init
- script: terraform plan
- script: terraform apply -auto-approve
```

## Cost Management

### Cost Estimation
```bash
# Use Infracost for cost estimation
infracost breakdown --path .
```

### Resource Tagging
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}
```

## Documentation

Each project should include:
- Purpose and scope
- Architecture diagrams
- Variable descriptions
- Example usage
- Prerequisites
- Deployment instructions