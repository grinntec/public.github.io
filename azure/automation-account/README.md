# Azure Automation Account Scripts

This directory contains runbooks and scripts designed for Azure Automation Account execution.

## Contents

- **AutomaticResourceDelete/** - Automated resource cleanup based on creation date
- **SendEmailSendGrid/** - Email notification functionality using SendGrid

## Overview

These scripts are designed to run in Azure Automation Account environments with managed identity authentication. They provide automated resource management and notification capabilities.

## Common Prerequisites

- Azure Automation Account with managed identity enabled
- Azure PowerShell modules installed in the Automation Account
- Key Vault access for API keys and secrets
- Appropriate RBAC permissions for resource management

## Security Considerations

- All scripts use managed identity for authentication
- Sensitive information (API keys) stored in Azure Key Vault
- Scripts follow principle of least privilege
- Comprehensive logging for audit trails