# Simplified function to send email notifications
function Send-EmailNotification {
    param (
        [string]$fromEmailAddress,
        [string]$destEmailAddress,
        [string]$subject,
        [string]$content,
        [string]$apiKey
    )

    try {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer " + $apiKey)
        $headers.Add("Content-Type", "application/json")

        $body = @{
            personalizations = @(
                @{
                    to = @(
                        @{
                            email = $destEmailAddress
                        }
                    )
                }
            )
            from = @{
                email = $fromEmailAddress
            }
            subject = $subject
            content = @(
                @{
                    type = "text/plain"
                    value = $content
                }
            )
        }

        $bodyJson = $body | ConvertTo-Json -Depth 4

        $response = Invoke-RestMethod -Uri "https://api.sendgrid.com/v3/mail/send" -Method Post -Headers $headers -Body $bodyJson

        Write-Log "Email notification sent. Response: $response"
    } catch {
        Write-Log "Failed to send email notification: $($_.Exception.Message)" -type "ERROR"
    }
}