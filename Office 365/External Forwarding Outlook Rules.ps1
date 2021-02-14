#Purpose: Will find anyone with Outlook rules that auto forward emails to external users. Report will only run on Tuesday's but this can be removed

$global:mailboxes              = Get-Mailbox -ResultSize Unlimited
$global:date                   = Get-Date -UFormat "%Y-%m-%d"
$global:logpath                = "C:\logs"

if ((Get-Date -Format "dddd") -like "*Tuesday*") {
        foreach ($mailbox in $mailboxes) {
                $forwardingRules = $null
                Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.userprincipalname)" -foregroundColor Green
                $rules = Get-InboxRule -Mailbox $mailbox.userprincipalname
                $forwardingRules = $rules | Where-Object {$_.forwardto -or $_.forwardasattachmentto}
                foreach ($rule in $forwardingRules) {
                    $recipients = @()
                    $recipients = $rule.ForwardTo | Where-Object {$_ -match "SMTP"}
                    $recipients += $rule.ForwardAsAttachmentTo | Where-Object {$_ -match "SMTP"}
                    $externalRecipients = @()
                    foreach ($recipient in $recipients) {
                        $email = ($recipient -split "SMTP:")[1].Trim("]")
                        $domain = ($email -split "@")[1]
                        if ($domains.DomainName -notcontains $domain) {
                            $externalRecipients += $email
                        }
                    }
                    if ($externalRecipients) {
                        $extRecString = $externalRecipients -join ", "
                        Write-Host "The Outlook rule '$($rule.Name)' forwards to $extRecString" -ForegroundColor Yellow

                        $ruleHash = $null
                        $ruleHash = [ordered]@{
                            PrimarySmtpAddress = $mailbox.userprincipalname
                            DisplayName        = $mailbox.DisplayName
                            RuleId             = $rule.Identity
                            RuleName           = $rule.Name
                            RuleDescription    = $rule.Description
                            ExternalRecipients = $extRecString
                        }
                        $ruleObject = New-Object PSObject -Property $ruleHash
                        $ruleObject | Export-Csv "$logpath\ExternalRules-$date.csv" -NoTypeInformation -Append
                    }
    }
}
