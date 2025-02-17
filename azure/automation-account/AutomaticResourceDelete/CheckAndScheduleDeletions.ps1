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

# Log messages
function Write-LogMessage {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    Write-Output "[$type] $message"
}

# Send email notifications
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

    Write-LogMessage -message "Preparing to send email notification..."
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

    Write-LogMessage -message "JSON payload:"
    Write-LogMessage -message $emailContent

    try {
        Write-LogMessage -message "Sending email using SendGrid API..."
        Write-LogMessage -message "SendGrid API Key length: $($sendGridApiKey.Length)"
        Invoke-RestMethod -Uri "https://api.sendgrid.com/v3/mail/send" -Method Post -Headers @{
            Authorization = "Bearer $sendGridApiKey"
            "Content-Type" = "application/json"
        } -Body $emailContent
        Write-LogMessage -message "Email notification sent for resource $resourceName."
    } catch {
        Write-LogMessage -message "Failed to send email notification: $_" -type "ERROR"
        throw $_
    }
}

# Authenticate to Azure
# Ensure AzContext is not inherited
Disable-AzContextAutosave -Scope Process 

# Authenticate using Managed Identity
$AzureContext = (Connect-AzAccount -Identity).Context
Set-AzContext -SubscriptionId $AzureContext.Subscription.Id | Out-Null

# Retrieve SendGrid API Key from Azure Key Vault
$VaultName = $vaultName
$sendGridApiKeySecure = Get-AzKeyVaultSecret -VaultName $VaultName -Name $secretName

# Convert SecureString to plain text
$sendGridApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sendGridApiKeySecure.SecretValue))

# Main script execution
try {
    $currentDate = Get-Date
    Write-LogMessage -message "Current date and time: $currentDate"

    Write-LogMessage -message "Retrieving all resource groups in the subscription..."
    $resourceGroups = Get-AzResourceGroup
    Write-LogMessage -message "Found $($resourceGroups.Count) resource groups."

    foreach ($resourceGroup in $resourceGroups) {
        $resourceGroupName = $resourceGroup.ResourceGroupName
        Write-LogMessage -message "Processing resource group: $resourceGroupName"

        Write-LogMessage -message "Retrieving resources in resource group: $resourceGroupName"
        $resources = Get-AzResource -ResourceGroupName $resourceGroupName
        Write-LogMessage -message "Found $($resources.Count) resources in resource group: $resourceGroupName"
        $allResourcesDeleted = $true

        foreach ($resource in $resources) {
            if ($resource.Tags -and $resource.Tags.ContainsKey("CreatedOnDate") -and -not $resource.Tags.ContainsKey("ExcludeFromDeletion")) {
                $createdOnDate = $resource.Tags["CreatedOnDate"]
                $deletionTime = if ($resource.Tags.ContainsKey("ScheduledDeletion")) { $resource.Tags["ScheduledDeletion"] } else { $null }

                if ($createdOnDate) {
                    $resourceCreatedDate = [datetime]::Parse($createdOnDate)
                    $ageInMinutes = ($currentDate - $resourceCreatedDate).TotalMinutes
                    Write-LogMessage -message "Resource $($resource.Name) created on $resourceCreatedDate (age: $ageInMinutes minutes)"

                    if ($deletionTime) {
                        $scheduledDeletion = [datetime]::Parse($deletionTime)
                        if ($currentDate -ge $scheduledDeletion) {
                            Remove-AzResource -ResourceId $resource.ResourceId -Force
                            Write-LogMessage -message "Deleted resource: $($resource.Name)"
                        } else {
                            Write-LogMessage -message "Resource $($resource.Name) scheduled for deletion at $scheduledDeletion"
                            $allResourcesDeleted = $false
                        }
                    } elseif ($ageInMinutes -gt 720) { # 12 hours = 720 minutes
                        $scheduledDeletion = $currentDate.AddHours(12)
                        $resource | Set-AzResource -Tag @{ "ScheduledDeletion" = $scheduledDeletion.ToString("o") } -Force
                        Write-LogMessage -message "Scheduled deletion for resource: $($resource.Name) at $scheduledDeletion."

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
            Write-LogMessage -message "Deleted resource group: $resourceGroupName"
        } else {
            Write-LogMessage -message "Resource group $resourceGroupName contains undeleted resources."
        }
    }

    Write-LogMessage -message "Runbook execution completed."
} catch {
    Write-LogMessage -message "Runbook execution failed: $_" -type "ERROR"
    throw $_
}
