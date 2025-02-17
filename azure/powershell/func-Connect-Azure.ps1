<#
.SYNOPSIS
    Function to authenticate to Azure using a managed identity and set the Azure context.

.DESCRIPTION
    This function authenticates to Azure using a system-assigned managed identity.
    It sets the Azure context to the subscription associated with the managed identity.
    The function logs the authentication process and handles any errors that occur during authentication.

.PARAMETER SubscriptionId
    The ID of the Azure subscription to set the context to. If not provided, the subscription ID from the authenticated context will be used.

.PARAMETER TenantId
    The ID of the Azure tenant to authenticate against. If not provided, the default tenant will be used.

.EXAMPLE
    # Example usage of Connect-Azure function
    try {
        $AzureContext = Connect-Azure -SubscriptionId "your-subscription-id" -TenantId "your-tenant-id"
        Write-Log "Azure context set successfully."
    } catch {
        Write-Log "Failed to set Azure context: $_" -type "ERROR"
    }

.NOTES
    Author: Neil (neil@grinntec.net)
    Creation Date: 2025-02-17
    Version: 1.0
#>

# Function to authenticate to Azure
function Connect-Azure {
    param (
        [string]$SubscriptionId,
        [string]$TenantId
    )

    Write-Log "Authenticating to Azure..."
    try {
        $AzureContext = if ($TenantId) {
            Connect-AzAccount -Identity -TenantId $TenantId
        } else {
            Connect-AzAccount -Identity
        }

        if (-not $SubscriptionId) {
            $SubscriptionId = $AzureContext.Context.Subscription.Id
        }

        if (-not $SubscriptionId) {
            throw "SubscriptionId is null or empty. Provide a valid SubscriptionId."
        }

        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        return $AzureContext.Context
    } catch {
        Write-Log "Failed to authenticate to Azure: $_" -type "ERROR"
        throw $_
    }
}