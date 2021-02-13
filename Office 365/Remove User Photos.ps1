#This script removes personally set pictures so a company wide picture can be set instead
#1. Remove all user photos
$mailboxes = Get-Mailbox -ResultSize Unlimited
$usermailboxes = $mailboxes | Where-Object RecipientTypeDetails -eq "UserMailbox"

foreach ($mailbox in $usermailboxes){
    Write-Host "Now checking $($mailbox.identity)"
    if ($mailbox.HasPicture -eq $true) {
        "","Removing picture for $($mailbox.identity)","" | Write-Host -BackgroundColor Black -ForegroundColor Yellow
        Remove-UserPhoto -Identity $mailbox.identity -Confirm:$false
    }
}

#2. Disable user ability to add user photos for existing and future mailboxes
Set-OwaMailboxPolicy -Identity Default -SetPhotoEnabled $false
Set-OwaMailboxPolicy -Identity "OwaMailboxPolicy-Default" -SetPhotoEnabled $false
