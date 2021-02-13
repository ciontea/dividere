#Find all contacts on-prem and how many contacts there are
#One liner to see all contacts in a table = Get-ADObject -Filter 'objectClass -eq "contact"' -Properties CN | Select-Object CN, Name, objectClass, ObjectGUID, DistinguishedName | Format-Table
#Find specific contacts = Get-ADObject -Filter {(objectClass -eq "contact") -and (cn -like "*Peter*")} -Properties *

#Connecting to Office 365
Connect-ExchangeOnline

#Variables needed
$ADcontacts = Get-ADObject -Filter 'objectClass -eq "contact"' -Properties CN, Mail -SearchBase 'OU=AllContacts,DC=contoso,DC=com'
$ADcontactscount = $ADcontacts.count
$o365contacts = Get-MailContact

<#

VERY IMPORTANT TO DO
Make sure these contacts are not being synced from on-prem AD or the contacts will disappear and you won't have a backup of the group memberships for where these contacts were
Commands below will show reoughly where the contacts are being used by any distribution groups but will not check usermailboxes or sharedmailboxes or any other forwarding rules or features, etc.

#TEST 1
$email = "bob@externalDomain.com"
$dn = (Get-MailContact $email).DistinguishedName
Get-Recipient -Filter "Members -eq '$dn'"

#TEST 2
$Username = "tom@externalDomain2.ca"
$DistributionGroups = Get-DistributionGroup | where { (Get-DistributionGroupMember $_.Name | foreach {$_.PrimarySmtpAddress}) -contains "$Username"}

#>

#Creating the new contacts in O365
foreach ($ADcontact in $ADcontacts) {
    $deletecontact = $null
    Write-Host "Now checking contact $($ADcontact.Name)"
    foreach ($o365contact in $o365contacts) {
        if ($ADcontact.Mail -eq $o365contact.PrimarySmtpAddress) {
            $deletecontact = $true
        }
    }
    if ($deletecontact) {
        "","User $($ADcontact.Name) will be deleted from AD because their email address $($ADcontact.Mail) already exists in Office 365","" | Write-Host -BackgroundColor Black -ForegroundColor Yellow
        Remove-ADObject $ADcontact.DistinguishedName -Confirm:$false
    } else {
        "","User $($ADcontact.Name) will added to Office 365 with the email address $($ADcontact.Mail) and then the AD contact will be removed","" | Write-Host -BackgroundColor Black -ForegroundColor Yellow
        New-MailContact -Name $ADcontact.Name -ExternalEmailAddress $ADcontact.Mail
        Remove-ADObject $ADcontact.DistinguishedName -Confirm:$false
    }
}
