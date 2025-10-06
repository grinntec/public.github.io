# Automatic Resource Delete

This script provides automated cleanup of Azure resources based on their creation date and lifecycle policies.

## Script: CheckAndScheduleDeletions.ps1

### Purpose
Automatically manages the lifecycle of Azure resources by:
- Identifying resources with `CreatedOnDate` tags
- Scheduling resources for deletion after a specified time period (default: 12 hours)
- Executing scheduled deletions when the time arrives
- Cleaning up empty resource groups
- Sending email notifications before deletion

### Parameters
- `vaultName` (Required) - Azure Key Vault name containing SendGrid API key
- `secretName` (Required) - Name of the secret containing SendGrid API key
- `fromEmail` (Required) - Sender email address for notifications
- `toEmail` (Required) - Recipient email address for notifications

### How It Works
1. **Resource Discovery**: Scans all resource groups in the subscription
2. **Age Evaluation**: Checks resources with `CreatedOnDate` tags
3. **Scheduling**: Resources older than 12 hours get tagged with `ScheduledDeletion`
4. **Notification**: Email sent to notify about scheduled deletion
5. **Execution**: Resources are deleted when their scheduled time arrives
6. **Cleanup**: Empty resource groups are automatically removed

### Tag-Based Control
- `CreatedOnDate` - Automatically added by Azure Policy (required for processing)
- `ScheduledDeletion` - Added by this script when scheduling deletion
- `ExcludeFromDeletion` - Resources with this tag are permanently excluded

### Prerequisites
- Azure Automation Account with managed identity
- Azure Key Vault with SendGrid API key
- PowerShell Az modules
- Resource Contributor permissions
- Tags applied via Azure Policy

### Usage
Typically scheduled as a recurring runbook in Azure Automation Account:

```powershell
.\CheckAndScheduleDeletions.ps1 -vaultName "myKeyVault" -secretName "sendgrid-api-key" -fromEmail "noreply@example.com" -toEmail "admin@example.com"
```

### Safety Features
- Only processes resources with proper tags
- Respects exclusion tags
- Provides 12-hour warning period
- Comprehensive logging
- Email notifications for transparency

### Email Notifications
HTML-formatted emails include:
- Subscription name
- Resource details (name, type, resource group)
- Scheduled deletion time
- Professional styling for clarity