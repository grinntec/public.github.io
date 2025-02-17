<#
.SYNOPSIS
    Function to retrieve a secret from Azure Key Vault.

.DESCRIPTION
    This function retrieves a secret from Azure Key Vault using the specified vault name and secret name.
    It logs the process of retrieving the secret and handles any errors that occur during the retrieval.

.PARAMETER vaultName
    The name of the Azure Key Vault from which to retrieve the secret.

.PARAMETER secretName
    The name of the secret to retrieve from the Azure Key Vault.

.EXAMPLE
    # Example usage of Get-SecretFromKeyVault function
    try {
        $secretValue = Get-SecretFromKeyVault -vaultName "myVault" -secretName "mySecret"
        Write-Log "Retrieved secret value: $secretValue"
    } catch {
        Write-Log "Failed to retrieve secret: $_" -type "ERROR"
    }

.NOTES
    Author: Neil (neil@grinntec.net)
    Creation Date: 2025-02-17
    Version: 1.0
#>

# Function to retrieve secret from Azure Key Vault
function Get-SecretFromKeyVault {
    param (
        [Parameter(Mandatory=$true)]
        [string]$vaultName,

        [Parameter(Mandatory=$true)]
        [string]$secretName
    )

    Write-Log "Retrieving secret from Azure Key Vault..."
    try {
        if (-not $vaultName) {
            throw "Vault name is null or empty. Provide a valid vault name."
        }
        if (-not $secretName) {
            throw "Secret name is null or empty. Provide a valid secret name."
        }

        $AzKeyVaultSecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName
        if ($null -eq $AzKeyVaultSecret) {
            Write-Log "Failed to retrieve secret from Azure Key Vault. Please verify the vault name and secret name." -type "ERROR"
            throw "Failed to retrieve secret."
        } else {
            $secretValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AzKeyVaultSecret.SecretValue))
            Write-Log "Secret retrieved successfully."
            return $secretValue
        }
    } catch {
        Write-Log "Failed to retrieve secret: $_" -type "ERROR"
        throw $_
    }
}