locals {
  tags = {
    app = var.prefix
    env = var.environment
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.prefix}-${var.environment}"
  location = var.resource_group_location
  tags     = local.tags
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

output "resource_group_name" {
  description = "The name of the resource group"  
  value = azurerm_resource_group.this.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value = azurerm_resource_group.this.location
}
