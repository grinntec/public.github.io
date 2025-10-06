# SendGrid Email Integration

This script provides email notification functionality using SendGrid API for Azure Automation Account runbooks.

## Script: Send-EmailViaSendGrid.ps1

### Purpose
Sends email notifications via SendGrid API with authentication through Azure Key Vault integration.

### Parameters
- `destEmailAddress` (Required) - Recipient email address
- `fromEmailAddress` (Required) - Sender email address
- `subject` (Required) - Email subject line
- `content` (Required) - Email body content (plain text)
- `vaultName` (Required) - Azure Key Vault name
- `secretName` (Required) - Secret name containing SendGrid API key

### Features
- **Managed Identity Authentication** - Uses Azure managed identity for Key Vault access
- **Secure API Key Retrieval** - Fetches SendGrid API key from Azure Key Vault
- **Plain Text Email** - Sends simple text-based emails
- **Error Handling** - Comprehensive error handling and logging
- **REST API Integration** - Direct SendGrid v3 API integration

### How It Works
1. **Authentication** - Connects to Azure using managed identity
2. **Secret Retrieval** - Gets SendGrid API key from Key Vault
3. **Email Construction** - Builds JSON payload for SendGrid API
4. **API Call** - Sends email via SendGrid REST API
5. **Response Handling** - Processes API response and logs results

### Prerequisites
- Azure Automation Account with managed identity
- Azure Key Vault with SendGrid API key stored as secret
- Key Vault access policy for the managed identity
- Valid SendGrid account and API key
- PowerShell Az modules

### Usage
```powershell
.\Send-EmailViaSendGrid.ps1 -destEmailAddress "user@example.com" -fromEmailAddress "noreply@example.com" -subject "Test Email" -content "Hello World" -vaultName "myKeyVault" -secretName "sendgrid-api-key"
```

### SendGrid API Integration
- Uses SendGrid v3 Mail Send API
- Bearer token authentication
- JSON payload format
- Content-Type: application/json

### Security Best Practices
- API key stored securely in Key Vault
- Managed identity authentication
- No hardcoded credentials
- Secure string handling for sensitive data

### Common Use Cases
- Automated notifications from runbooks
- Alert emails for resource lifecycle events
- Status updates for long-running processes
- Error notifications for failed automation tasks