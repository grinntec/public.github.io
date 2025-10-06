# PowerShell Functions for Azure

This directory contains reusable PowerShell functions for common Azure operations. These functions can be imported and used in larger scripts or runbooks.

## Functions Overview

### func-Connect-Azure.ps1
**Purpose**: Authenticate to Azure using managed identity and set the Azure context.

**Features**:
- Managed identity authentication
- Azure context configuration
- Subscription and tenant ID support
- Error handling and logging
- Context inheritance prevention

**Parameters**:
- `SubscriptionId` (Optional) - Target subscription ID
- `TenantId` (Optional) - Target tenant ID

### func-Get-SecretFromKeyVault.ps1
**Purpose**: Retrieve secrets from Azure Key Vault with proper error handling.

**Features**:
- Secure secret retrieval
- SecureString to plain text conversion
- Comprehensive error handling
- Logging integration

**Parameters**:
- `vaultName` (Required) - Key Vault name
- `secretName` (Required) - Secret name to retrieve

### func-Send-EmailNotification.ps1
**Purpose**: Send email notifications using SendGrid API.

**Features**:
- SendGrid v3 API integration
- JSON payload construction
- Bearer token authentication
- Error handling

**Parameters**:
- `fromEmailAddress` (Required) - Sender email
- `destEmailAddress` (Required) - Recipient email
- `subject` (Required) - Email subject
- `content` (Required) - Email content
- `apiKey` (Required) - SendGrid API key

### func-Write-Log.ps1
**Purpose**: Standardized logging function for consistent output formatting.

**Features**:
- Structured log messages
- Log level support (INFO, ERROR, WARNING, etc.)
- Timestamp formatting
- Console output

**Parameters**:
- `message` (Required) - Log message
- `type` (Optional) - Log level (default: "INFO")

## Usage Examples

### Import and Use Functions
```powershell
# Import functions
. .\func-Connect-Azure.ps1
. .\func-Write-Log.ps1
. .\func-Get-SecretFromKeyVault.ps1

# Use functions
try {
    $context = Connect-Azure -SubscriptionId "your-sub-id"
    Write-Log "Connected to Azure successfully"
    
    $secret = Get-SecretFromKeyVault -vaultName "myVault" -secretName "mySecret"
    Write-Log "Retrieved secret successfully"
} catch {
    Write-Log "Operation failed: $_" -type "ERROR"
}
```

### Automation Account Integration
These functions are designed for use in Azure Automation Account runbooks:

```powershell
# In a runbook
Param(
    [string]$keyVaultName,
    [string]$secretName
)

# Import functions (if stored as Automation Account assets)
. .\func-Connect-Azure.ps1
. .\func-Get-SecretFromKeyVault.ps1
. .\func-Write-Log.ps1

# Use in runbook logic
$context = Connect-Azure
$apiKey = Get-SecretFromKeyVault -vaultName $keyVaultName -secretName $secretName
Write-Log "Runbook execution completed"
```

## Design Principles

- **Modularity**: Each function serves a specific purpose
- **Reusability**: Functions can be used across multiple scripts
- **Error Handling**: Comprehensive try-catch blocks and validation
- **Logging**: Consistent logging for troubleshooting
- **Security**: Secure handling of sensitive data
- **Documentation**: Full comment-based help for each function

## Prerequisites

- Azure PowerShell module (Az)
- Appropriate Azure permissions
- Azure Key Vault access (where applicable)
- SendGrid account (for email functions)

## Best Practices

- Always import required functions at the beginning of scripts
- Use try-catch blocks when calling functions
- Implement proper logging for audit trails
- Store sensitive data in Key Vault, not in scripts
- Test functions individually before integration