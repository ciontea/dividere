#This script can definitely be optimized but I had created this in a rush against time
#Connecting to Exchange Online
Connect-ExchangeOnline

#Variables needed
$path1 = 'ou=userlist1,dc=contoso,dc=com'
$path2 = 'ou=userlist2,dc=contoso,dc=com'
$path3 = 'ou=userlist3,dc=contoso,dc=com'
$path4 = 'ou=userlist4,dc=contoso,dc=com'
$exportpath = "C:\temp david c"
$allusers = Get-ADUser -Filter * -SearchBase $path1 -properties *
$allusers += Get-ADUser -Filter * -SearchBase $path2 -properties *
$allusers += Get-ADUser -Filter * -SearchBase $path3 -properties *
$allusers2 = Get-ADUser -Filter * -SearchBase $path4 -properties *
$oallusers = Get-DistributionGroupMember -Identity "DG1"
$oallusers2 = Get-DistributionGroupMember -Identity "DG2"
$alreadyadded = @()
$alreadyadded2 = @()
$addedusers = @()
$addedusers2 = @()

#Backing up the information before making the changes
New-Item -ItemType Directory -Path $exportpath
Get-DistributionGroupMember -Identity "DG1" | Select-Object Name | Out-File "$exportpath\O365 DG1 Users List.txt" -Encoding utf8
Get-DistributionGroupMember -Identity "DG2" | Select-Object Name | Out-File "$exportpath\O365 DG2 Users List.txt" -Encoding utf8

foreach ($user in $allusers) {
    if ($null -ne $user.EmailAddress) {
        foreach ($uuser in $oallusers) {
            if ($user.Name -eq $uuser.name) {
                $useralreadyadded = $true
            }
        }

        if ($useralreadyadded) {
            $alreadyadded += $user.Name
        } else {
            $addedusers += $user.Name
            Add-DistributionGroupMember -Identity "DG1" -Member $user.EmailAddress
        }

        $useralreadyadded = $null
    }
}

$useralreadyadded = $null

foreach ($user in $allusers2) {
    if ($null -ne $user.EmailAddress) {
        foreach ($uuser in $oallusers2) {
            if ($user.Name -eq $uuser.name) {
                $useralreadyadded = $true
            }
        }

        if ($useralreadyadded) {
            $alreadyadded2 += $user.Name
        } else {
            $addedusers2 += $user.Name
            #Add-DistributionGroupMember -Identity "DG2" -Member $user.EmailAddress
        }

        $useralreadyadded = $null
    }
}

<#
foreach ($user in $alreadyadded) {Write-Host "$user is already added to 'DG1'"}
"","" | Write-Host
foreach ($user in $alreadyadded2) {Write-Host "$user is already added to 'DG2'"}
"","" | Write-Host
#>
foreach ($user in $addedusers) {Write-Host "Added $user to dsitribution group 'DG1'"}
"","" | Write-Host
foreach ($user in $addedusers2) {Write-Host "Added $user to dsitribution group 'DG2'"}




Add-DistributionGroupMember -Identity "DG1" -Member $user.EmailAddress
Add-DistributionGroupMember -Identity "DG2" -Member $user.EmailAddress
