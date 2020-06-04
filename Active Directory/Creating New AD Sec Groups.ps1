<#
PURPOSE: Create 3 Active Directory Security groups for each of the folders in your network share so you just add users to these groups instead of granting them explicit NTFS permissions
NOTE: The security group names will be in all capitals and any spaces will be replaced with underscores "_"
HOW TO USE: Replace the two variables at the top of this script and then run it
#>

$serverpath = "\\server\sharename"
$locationforgroups = "OU=This is where the security groups are stored,DC=domain,DC=com"

#Creating the groups needed
$folders = (Get-ChildItem $serverpath).Name

foreach ($folder in $folders) {
    #Replacing spaces in the name with underscores
    $folder = $folder –replace “ “,”_”
    
    #Creating the RO Groups
    $foldernamero = $folder.ToUpper() + "_RO"
    $folderrotrue = try {Get-ADGroup $foldernamero} catch {$folderrotrue = $null}
    if ($null -eq $folderrotrue) {
        Write-Host "Creating RO group $foldernamero"
        New-ADGroup -Name $foldernamero -Path $locationforgroups -GroupScope Global
    } else {
        Write-Host "$foldernamero Group already exists"
    }

    #Creating the RW Groups
    $foldernamerw = $folder.ToUpper() + "_RW"
    $folderrwtrue = try {Get-ADGroup $foldernamerw} catch {$folderrwtrue = $null}
    if ($null -eq $folderrwtrue) {
        Write-Host "Creating RW group $foldernamerw"
        New-ADGroup -Name $foldernamerw -Path $locationforgroups -GroupScope Global
    } else {
        Write-Host "$foldernamerw Group already exists"
    }

    #Creating the List Groups
    $foldernamelist = $folder.ToUpper() + "_LIST"
    $folderlisttrue = try {Get-ADGroup $foldernamelist} catch {$folderlisttrue = $null}
    if ($null -eq $folderlisttrue) {
        Write-Host "Creating LIST group $foldernamelist"
        New-ADGroup -Name $foldernamelist -Path $locationforgroups -GroupScope Global
    } else {
        Write-Host "$foldernamelist Group already exists"
    }
}
