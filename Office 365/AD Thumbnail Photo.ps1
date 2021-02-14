#Purpose: Setting AD attribute ThumbnailPhoto so new users will have the correct logo showing in their Micorosft Teams account, Outlook and other services

$global:adPhoto              = [byte[]](Get-Content "C:\logo.jpg" -Encoding byte) #Please make sure this picture is no larger than 100KB
$global:adUsers              = Get-ADUser -Filter * -Properties * | Sort-Object Name
$global:mailboxes            = Get-Mailbox -ResultSize Unlimited
$global:usermailboxes        = $mailboxes | Where-Object RecipientTypeDetails -eq "UserMailbox"

#Setting AD attribute ThumbnailPhoto so new users will have the correct logo showing in their Micorosft Teams account and other services
            foreach ($user in $adUsers) {
                Write-Host "Now checking the AD user $($user.Name) for their 'ThumbnailPhoto' attribute"
                if ([string]$user.ThumbnailPhoto -ne [string]$adPhoto) {
                    "","Fixing 'ThumbnailPhoto' for $($user.Name)" | Write-Host -BackgroundColor Yellow -ForegroundColor Black
                    $user.thumbnailPhoto = $adPhoto

                    #Finalizing the AD User changes
                        Set-ADUser -Instance $user
                    #Pushing above changes to the cloud too
                        foreach ($userMailbox in $usermailboxes) {
                            if ($user.Name -eq $userMailbox.Name) {
                                $hasMailbox = $true
                            }
                        }

                        if ($hasMailbox) {
                            "Pushing changes to the Exchange Online as well","" | Write-Host -BackgroundColor Yellow -ForegroundColor Black
                            Set-UserPhoto -Identity $user.UserPrincipalName -PictureData $adPhoto -Confirm:$false
                        } else {
                            "" | Write-Host -BackgroundColor Yellow -ForegroundColor Black
                        }
                        $hasMailbox = $null
                }
            }
