<#
Scenario:
User A has left the company a month ago and the IT department has deleted User A’s AD account which removes the license from O365 and the account itself but changes the mailbox to an inactive mailbox since it is on indefinite litigation hold. User A is now hired back to the company and we would like to have the old emails move back to the user’s mailbox. We have two options, restore or recover which are explained below

Pre-Req:
    a.	Use these steps for when you would like the inactive mailbox to remain untouched but the emails to be copied over to the new primary mailbox https://docs.microsoft.com/en-us/microsoft-365/compliance/restore-an-inactive-mailbox?view=o365-worldwide
    b.	Create a new AD account for User A
    c.	Sync the changes to O365
    d.	Assign an E3 license to User A
    e.	Wait for the new mailbox to be created fully
    f.	Connect to Exchange Online PowerShell
#>

#Restore (copy) an inactive mailbox to a new mailbox. Inactive mailbox will NOT be removed. If you need the inactive mailbox removed, please look up documentation as you need other switches/parameters on New-MailboxRestoreRequest
$user = "bob.george@contoso.com"
[string]$inactiveMailbox = (Get-Mailbox -InactiveMailboxOnly -Identity $user).ExchangeGuid
[string]$activeMailbox = (Get-Mailbox -Identity $user).GUID
New-MailboxRestoreRequest -SourceMailbox $inactiveMailbox -TargetMailbox $activeMailbox -AllowLegacyDNMismatch

#Recover (move) an inactive mailbox to a new mailbox. Inactive mailbox WILL be removed
# https://docs.microsoft.com/en-us/microsoft-365/compliance/recover-an-inactive-mailbox?view=o365-worldwide 

#Optional: After a while, make sure to run the command below to clear up the logs
Get-MailboxRestoreRequest -Status Completed | Remove-MailboxRestoreRequest
<#
If the above command fails because it matches multiple entries, please run the following commands
    Get-MailboxRestoreRequest -Status Completed | Select-Object Identity,RequestGuid
    #Now find the correct RequestGuid of the request you want to remove
    Remove-MailboxRestoreRequest -Identity <use the RequestGuid from the above command>

If you know that you only ran one request then run this one-liner
    (Get-MailboxRestoreRequest -Status Completed).RequestGuid | Remove-MailboxRestoreRequest
#>
