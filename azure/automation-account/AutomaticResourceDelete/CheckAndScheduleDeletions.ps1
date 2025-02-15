<#
.SYNOPSIS
    PowerShell script to check and schedule resource deletions in Azure and send email notifications.

.DESCRIPTION
    This script authenticates to Azure using a managed identity, retrieves all resource groups and resources within the subscription, and checks for resources tagged with a creation date. If the resources do not have a tag to exclude them from deletion and are older than 12 hours, they are scheduled for deletion 12 hours in the future. An email notification is sent with the details of the scheduled deletion.

.PARAMETER vaultName
    The name of the Azure Key Vault to retrieve the SendGrid API key.

.PARAMETER secretName
    The name of the secret in the Azure Key Vault containing the SendGrid API key.

.PARAMETER fromEmail
    The email address to send the notifications from.

.PARAMETER toEmail
    The email address to send the notifications to.

.AUTHOR
    Neil (neil@grinntec.net)

.CREATION DATE
    2025-02-15

.VERSION
    1.0

.EXAMPLE
    .\CheckAndScheduleDeletions.ps1 -vaultName "myVault" -secretName "mySecret" -fromEmail "sender@example.com" -toEmail "recipient@example.com"
#>

Param(
    [Parameter(Mandatory=$true)]
    [string] $vaultName,
    
    [Parameter(Mandatory=$true)]
    [string] $secretName,
    
    [Parameter(Mandatory=$true)]
    [string] $fromEmail,
    
    [Parameter(Mandatory=$true)]
    [string] $toEmail
)

# Function to log messages
function Write-Log {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    Write-Output "[$type] $message"
}

# Function to send email notifications
function Send-EmailNotification {
    param (
        [string]$subscriptionName,
        [string]$resourceName,
        [string]$resourceType,
        [string]$resourceGroupName,
        [datetime]$deletionTime,
        [string]$fromEmail,
        [string]$toEmail,
        [string]$sendGridApiKey
    )

    Log-Message "Preparing to send email notification..."
    $emailBody = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { padding: 20px; }
        .header { font-size: 18px; font-weight: bold; }
        .content { margin-top: 20px; }
        .content p { margin: 5px 0; }
        .content .label { font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">Resource Deletion Notification</div>
        <div class="content">
            <p>Hello,</p>
            <p>The following resource is scheduled for deletion:</p>
            <p class="label">Subscription Name:</p> <p>$subscriptionName</p>
            <p class="label">Resource Name:</p> <p>$resourceName</p>
            <p class="label">Resource Type:</p> <p>$resourceType</p>
            <p class="label">Resource Group:</p> <p>$resourceGroupName</p>
            <p class="label">Scheduled Deletion:</p> <p>$deletionTime</p>
            <p>To prevent deletion, please remove or update the 'ScheduledDeletion' tag on the resource.</p>
            <p>Thank you.</p>
        </div>
    </div>
</body>
</html>
"@

    $emailContent = @{
        personalizations = @(@{ to = @(@{ email = $toEmail }) })
        from = @{ email = $fromEmail }
        subject = "Resource Deletion Notification: $resourceName"
        content = @(@{ type = "text/html"; value = $emailBody })
    } | ConvertTo-Json -Depth 5

    Log-Message "JSON payload:"
    Log-Message $emailContent

    try {
        Log-Message "Sending email using SendGrid API..."
        Invoke-RestMethod -Uri "https://api.sendgrid.com/v3/mail/send" -Method Post -Headers @{
            Authorization = "Bearer $sendGridApiKey"
            "Content-Type" = "application/json"
        } -Body $emailContent
        Log-Message "Email notification sent for resource $resourceName."
    } catch {
        Log-Message "Failed to send email notification: $_" -type "ERROR"
    }
}

# Function to authenticate to Azure
function Connect-Azure {
    Log-Message "Authenticating to Azure..."
    try {
        $AzureContext = (Connect-AzAccount -Identity).Context
        Set-AzContext -SubscriptionId $AzureContext.Subscription.Id | Out-Null
        Log-Message "Authenticated to Azure with subscription ID: $($AzureContext.Subscription.Id)"
        return $AzureContext
    } catch {
        Log-Message "Failed to authenticate to Azure: $_" -type "ERROR"
        throw $_
    }
}

# Function to retrieve SendGrid API Key from Azure Key Vault
function Get-SendGridApiKey {
    param (
        [string]$vaultName,
        [string]$secretName
    )

    Log-Message "Retrieving SendGrid API Key from Azure Key Vault..."
    try {
        $sendGridApiKeySecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName
        if ($null -eq $sendGridApiKeySecret) {
            Log-Message "Failed to retrieve SendGrid API Key from Azure Key Vault. Please verify the vault name and secret name." -type "ERROR"
            throw "Failed to retrieve SendGrid API Key."
        } else {
            $sendGridApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sendGridApiKeySecret.SecretValue))
            Log-Message "SendGrid API Key retrieved."
            return $sendGridApiKey
        }
    } catch {
        Log-Message "Failed to retrieve SendGrid API Key: $_" -type "ERROR"
        throw $_
    }
}

# Main script execution
try {
    $AzureContext = Connect-Azure
    $sendGridApiKey = Get-SendGridApiKey -vaultName $vaultName -secretName $secretName

    $currentDate = Get-Date
    Log-Message "Current date and time: $currentDate"

    Log-Message "Retrieving all resource groups in the subscription..."
    $resourceGroups = Get-AzResourceGroup
    Log-Message "Found $($resourceGroups.Count) resource groups."

    foreach ($resourceGroup in $resourceGroups) {
        $resourceGroupName = $resourceGroup.ResourceGroupName
        Log-Message "Processing resource group: $resourceGroupName"

        Log-Message "Retrieving resources in resource group: $resourceGroupName"
        $resources = Get-AzResource -ResourceGroupName $resourceGroupName
        Log-Message "Found $($resources.Count) resources in resource group: $resourceGroupName"
        $allResourcesDeleted = $true

        foreach ($resource in $resources) {
            if ($resource.Tags -and $resource.Tags.ContainsKey("CreatedOnDate") -and -not $resource.Tags.ContainsKey("ExcludeFromDeletion")) {
                $createdOnDate = $resource.Tags["CreatedOnDate"]
                $deletionTime = if ($resource.Tags.ContainsKey("ScheduledDeletion")) { $resource.Tags["ScheduledDeletion"] } else { $null }

                if ($createdOnDate) {
                    $resourceCreatedDate = [datetime]::Parse($createdOnDate)
                    $ageInMinutes = ($currentDate - $resourceCreatedDate).TotalMinutes
                    Log-Message "Resource $($resource.Name) created on $resourceCreatedDate (age: $ageInMinutes minutes)"

                    if ($deletionTime) {
                        $scheduledDeletion = [datetime]::Parse($deletionTime)
                        if ($currentDate -ge $scheduledDeletion) {
                            Remove-AzResource -ResourceId $resource.ResourceId -Force
                            Log-Message "Deleted resource: $($resource.Name)"
                        } else {
                            Log-Message "Resource $($resource.Name) scheduled for deletion at $scheduledDeletion"
                            $allResourcesDeleted = $false
                        }
                    } elseif ($ageInMinutes -gt 720) { # 12 hours = 720 minutes
                        $scheduledDeletion = $currentDate.AddHours(12)
                        $resource | Set-AzResource -Tag @{ "ScheduledDeletion" = $scheduledDeletion.ToString("o") } -Force
                        Log-Message "Scheduled deletion for resource: $($resource.Name) at $scheduledDeletion."

                        Send-EmailNotification -subscriptionName $AzureContext.Subscription.Name -resourceName $resource.Name -resourceType $resource.ResourceType -resourceGroupName $resourceGroupName -deletionTime $scheduledDeletion -fromEmail $fromEmail -toEmail $toEmail -sendGridApiKey $sendGridApiKey

                        $allResourcesDeleted = $false
                    } else {
                        $allResourcesDeleted = $false
                    }
                } else {
                    $allResourcesDeleted = $false
                }
            } else {
                $allResourcesDeleted = $false
            }
        }

        if ($allResourcesDeleted) {
            Remove-AzResourceGroup -Name $resourceGroupName -Force
            Log-Message "Deleted resource group: $resourceGroupName"
        } else {
            Log-Message "Resource group $resourceGroupName contains undeleted resources."
        }
    }

    Log-Message "Runbook execution completed."
} catch {
    Log-Message "Runbook execution failed: $_" -type "ERROR"
    throw $_
}