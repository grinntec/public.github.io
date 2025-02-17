# Function to log messages
function Write-Log {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    Write-Output "[$type] $message"
}