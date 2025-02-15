locals {
  tags = {
    app = var.prefix
    env = var.environment
  }
}

resource "azurerm_static_site" "this" {
  name                = "stapp-${var.prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku_size            = var.sku_size
  tags                = local.tags
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group where the workload will be managed"
}

variable "resource_group_location" {
  type        = string
  description = <<EOT
  (Required) Location of the resource group where the workload will be managed

  Options:
  - westeurope; west europe
  - eastus; east us
  - southeastasia; south east asia
  EOT

  validation {
    condition     = can(regex("^westeurope$|^eastus$|^southeastasia$|^west europe$|^east us$|^south east asia$", var.resource_group_location))
    error_message = "Err: location is not valid."
  }
}

variable "environment" {
  type        = string
  description = <<EOT
  (Required) Describe the environment type

  Options:
  - dev
  - test
  - prod
  EOT

  validation {
    condition     = can(regex("^dev$|^test$|^prod$", var.environment))
    error_message = "Err: Valid options are dev, test, or prod."
  }
}

variable "prefix" {
  description = "(Required) Name of the workload"
  type        = string
}


variable "sku_size" {
  type        = string
  description = <<EOT
  (Optional) Set the hosting plan
  
  Free is recommened For hobby or personal projects.
  Standard is or general purpose production apps
  
  Options:
  - Free
  - Standard

  EOT

  default = "Free"

  validation {
    condition     = can(regex("^Free$|^Standard$", var.sku_size))
    error_message = "Err: Valid options are Free, Standard."
  }
}

output "static_app_deployment_token" {
  description = "This token is used by deployment workflows to authenticate with the Static Web App."
  value       = azurerm_static_site.this.api_key
}
