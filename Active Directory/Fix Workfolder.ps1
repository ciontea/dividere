<#
PURPOSE: 
    -Sets the permission to each user's WorkFolders folder so only they can access their own
    -Administrators will only have access to folders of which there is no longer an active AD account associated to it or have the ending .OLD in the foldername (not filename)

OVERVIEW:
    -Finds all the ACLs of the folders in the syncshare
    -Creates a .csv backup of the pre-existing permissions
    -Goes through each folder to and performs the following
        -Disables inheritance on the folder
        -Removes all existing permissions on the folder
        -Determines if there is an existing Active Directory account for the folder to lock it down to and if not it gets locked down to Domain Admins

NOTES:
    -A trick to finding the permissions you want to set is to go through the GUI and add any random account to the test folder
        -Let's say you add "CONTOSO\Bob" with advanced NTFS permissions to "C:\test". Run the commands below to see what the permissions look like in PowerShell
            $acl = Get-Acl "C:\test"
            $acl.access
        -You will now be looking for the following properties from the output of that last command
            -FileSystemRights
            -AccessControlType
            -IdentityReference
            -InheritanceFlags
            -PropagationFlags
    -InheritanceFlags and PropagationFlags are to be used in conjunction to get the final result that you see in the advanced NTFS gui property called "Applies to: This Folder, subfolders and files"
    -It is ideal to run this script on the file server of which the workfolders permissions need to be changed
    -With the $acl.Sddl in the backup section, you can run the command below to get more info on the permissions
        ConvertFrom-SddlString -Sddl $acl.Sddl

ADDITIONAL RESOURCES:
    -https://blue42.net/windows/changing-ntfs-security-permissions-using-powershell/

COMMAND ALTERNATIVES:
    -Removing Permissions
        -Option 1 to remove very specific permissions not needed
            $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("CONTOSO\Bob","FullControl","Allow")
            foreach ($acl in $userfolderpermissions) {
                $acl.RemoveAccessRule($accessrule)
                $acl | Set-Acl $acl.path
            }
        -Option 2 to remove permissions not needed - This will completely purge the user
            $accessrule = New-Object System.Security.Principal.Ntaccount ("CONTOSO\Bob")
            foreach ($acl in $userfolderpermissions) {
                $acl.PurgeAccessRule($accessrule)
                $acl | Set-Acl $acl.path
            }
        -Option 3 to remove permissions not needed - Remove all ACL permissions - This is the one that is currently being used for the script
            $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
    -Find all available advanced NTFS permissions
        [system.enum]::getnames([System.Security.AccessControl.FileSystemRights])
#>

########################## Variables to Change ##########################
$manualexceptions = @()                                     #This is where you will type out any folders you wish to exclude from permissions changes
$adusers = Get-ADUser -Filter *                             #May want to restrict the -SearchBase to where only active AD accounts are stored so that Administrators can have folder access to inactive ones
$exportpath = 'C:\temp\Work Folders Permission Changes'     #This is where the csv showing all previous NTFS permissions will be stored
$domainname = "CONTOSO"
$workfolderspath = "\\workfolders server\syncsharename"
$syncStatePath = "E:\SyncShareState\Users Shared Folders"
$SPECIFICUSER = "dciontea" #This must be the name of their SamAccountName in ADUC. Example: dciontea or cdeorajh

########################## Functions Needed ##########################
function setDomainAdmin {
    Write-Host "$($acl.PSChildName) Folder does not have an associated AD account therefore access will be restricted to only Domain Admins" -BackgroundColor Black -ForegroundColor Yellow
    #Disabling inheritance on the folder. To enable inheritance again, flip this section to $false,$true instead of $true,$false
        $acl.SetAccessRuleProtection($true,$false)
    #Remove all ACL permissions now that the inherited permissions are gone
        $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
    #Setting the owner of the folder
        $aclOwner = "Domain Admins"
        $owner = New-Object System.Security.Principal.Ntaccount("$domainName\$aclOwner")
    #Change the owner of the folder only if it needs to
        if ($acl.Owner -ne $owner) {
            $acl.SetOwner($owner)
        }
    #Adding the correct permissions. The order of the command below can be found by running $acl.access which should show identity, fileSystemRights, inheritanceFlags, propagationFlags (not needed so leave blank), type
        $accessrule = @()
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$domainName\$aclOwner","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$domainName\DATA_RW","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$domainName\Domain Admins","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$domainName\admworkfolders","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        foreach ($rule in $accessrule) {
            $acl.SetAccessRule($rule) #The for loop is required or the command won't run, can't save these 3 lines of code
        }
    #Making the permissions changes
        $acl | Set-Acl $acl.path
}
function setDomainUser {
    Write-Host "The owner of folder $($acl.PSChildName) is AD User $aclOwner" -BackgroundColor Black
    #Disabling inheritance on the folder. To enable inheritance again, flip this section to $false,$true instead of $true,$false
        $acl.SetAccessRuleProtection($true,$false)
    #Remove all ACL permissions now that the inherited permissions are gone
        $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
    #Setting the owner of the folder
        $owner = New-Object System.Security.Principal.Ntaccount("$domainName\$aclOwner")
        if ($acl.Owner -notlike "*$aclOwner*") {
            $acl.SetOwner($owner)
        }
    #Adding the correct permissions. The order of the command below can be found by running $acl.access which should show identity, fileSystemRights, inheritanceFlags, propagationFlags (not needed so leave blank), type
        $accessrule = @()
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$domainName\$aclOwner","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$domainName\admworkfolders","FullControl","ContainerInherit, ObjectInherit","None","Allow")
        foreach ($rule in $accessrule) {
            $acl.SetAccessRule($rule) #The for loop is required or the command won't run, can't save these 3 lines of code
        }
    #Making the permissions changes
        $acl | Set-Acl $acl.path
}
function changeSubfolderPermissions {
    #Gaining access to the user's parent folder
        #Disabling inheritance on the folder. To enable inheritance again, flip this section to $false,$true instead of $true,$false
            $acl.SetAccessRuleProtection($true,$false)
        #Remove all ACL permissions now that the inherited permissions are gone
            $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
        #Setting the owner of the folder
            $owner = New-Object System.Security.Principal.Ntaccount("$currentUser")
            $acl.SetOwner($owner)

        #Adding the correct permissions. The order of the command below can be found by running $acl.access which should show identity, fileSystemRights, inheritanceFlags, propagationFlags (not needed so leave blank), type
            $accessrule = @()
            $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$currentUser","FullControl","ContainerInherit, ObjectInherit","None","Allow")
            foreach ($rule in $accessrule) {
                $acl.SetAccessRule($rule) #The for loop is required or the command won't run, can't save these 3 lines of code
            }
        #Making the permissions changes
            $acl | Set-Acl $acl.path
    #Making sure inheritance is enabled on all subfolders and objects within the parent folder since this is how WorkFolders assigns the permissions
        $aclPath = ($acl.path).Replace("Microsoft.PowerShell.Core\FileSystem::","")
        $subFolders = Get-ChildItem $aclPath
        $subUserFolderPermissions = @()

        foreach ($sFolder in $subFolders) {
            $subUserFolderPermissions += Get-Acl "$aclPath\$sFolder"
        }

        foreach ($sAcl in $subUserFolderPermissions) {
            if ($sAcl.AreAccessRulesProtected -eq $true) {
                #Enabling inheritance on the folder. To enable inheritance again, flip this section to $false,$true instead of $true,$false
                    $sAcl.SetAccessRuleProtection($false,$true)
                #Remove all ACL permissions now that the inherited permissions are gone
                    $sAcl.Access | ForEach-Object {$sAcl.RemoveAccessRule($_)}
                #Making the permissions changes
                    $sAcl | Set-Acl $sAcl.path
            }
        }
}

########################## Grabbing the ACL (permissions) and AD user information from the folders ##########################
    $userFolders = Get-ChildItem $workFoldersPath -Directory
    $exceptionFolders = @()
    $userFolderPermissions = @()

    if ($null -eq $SPECIFICUSER) {
        foreach ($folder in $userFolders) {
            $continue = $null
            foreach ($exception in $manualExceptions) {
                if ($folder.Name -like "*$exception*") {
                    $continue = $false
                }
            }
            if ($continue -ne $false) {
                try {
                    $userFolderPermissions += Get-Acl "$workFoldersPath\$folder"
                } catch {
                    $exceptionFolders += $folder
                }
            }
        }
        $exceptionFolders += $manualExceptions
        foreach ($exception in $exceptionFolders) {
            Write-Host "$exception folder's permissions will not be changed or you do not have permissions to this folder" -BackgroundColor Black -ForegroundColor Yellow
        }
    } else {
        $userFolderPermissions += Get-Acl "$workFoldersPath\$SPECIFICUSER"
    }

########################## Backing up the current permissions to a csv if a rollback is needed ##########################
#VERY IMPORTANT: This does not create a record of all NTFS settings but only the ones we require
#Creating the folder for the backup if not already created
if ($null -eq $SPECIFICUSER) {
    try {
        if (!(Test-Path $exportPath)) {New-Item -ItemType Directory -Path $exportPath}
    } catch {
        New-Item -ItemType Directory -Path $exportPath
    }

    foreach ($ace in $userFolderPermissions) {
        $ruleHash = $null
        $aclAccess = @()

        for ($i = 0; $i -lt (($ace.Access).count)-1; $i++) {
            $aclAccess += $ace.Access.IdentityReference.Value[$i] + "," +
            $ace.Access.FileSystemRights[$i] + "," +
            $ace.Access.AccessControlType[$i] + "," +
            $ace.Access.IsInherited[$i] + "," +
            $ace.Access.InheritanceFlags[$i] + "," +
            $ace.Access.PropagationFlags[$i]
        }
        $aclAccess = $aclAccess -join ' ; '

        $ruleHash = [ordered]@{
            PSPath          = $ace.PSPath
            PSChildName     = $ace.PSChildName
            Access          = $ace.aclAccess
            Owner           = $ace.Owner
            Path            = $ace.Path #This is added because in some scenarios it can be different than the PSPath
            Sddl            = $ace.Sddl
        }
        $ruleObject = New-Object PSObject -Property $ruleHash
        $ruleObject | Export-Csv "$exportPath\$(Get-Date -UFormat "%Y-%m-%d, Time (24-HR EST) %H-%M").csv" -NoTypeInformation -Append
    }
}

########################## Making the required changes ##########################
#Stopping the workfolders service just in case it causes any issues
if ($null -eq $SPECIFICUSER) {Stop-Service "Windows Sync Share"}
    #If the service ever fails to stop, open task manager > services tab > find the PID number of the service that has the description "Windows Sync Share" and run this command below
    #taskkill /f /pid [PID]

foreach ($acl in $userFolderPermissions) {
    $continue = $null
    $hasOwner = $null

    foreach ($exception in $manualExceptions) {
        if ($exception -like $acl.PSChildName) {
            $continue = $false
        }
    }

    if ($continue -ne $false) {
        if ($acl.Path -notlike "*.OLD*") {
            $aclOwner = @()

            foreach ($aduser in $adUsers) {
                if ($aduser.SamAccountName -like $acl.PSChildName) {
                    $hasOwner = $true
                    $aclOwner = $aduser.SamAccountName
                }
            }
            if ($hasOwner) {
                changeSubfolderPermissions
                setDomainUser

                #Fixing the sync now that the permission changes have been made. This is only done for domain user because they have an active AD account that is still syncing
                    takeown /F "$syncStatePath\$aclOwner@$domainName" /R /A /D Y
                    Remove-Item -Path "$syncStatePath\$aclOwner@$domainName" -Force -Recurse
                    if ($null -ne $SPECIFICUSER) {Repair-SyncShare -User $aclOwner -Name "Users Shared Folders" -Verbose} #The command is to be run only when running this script for a specific user for reason below
                    <#
                    Reason why Repair-SyncShare is not part of the script anymore for everyone is because it forces the user to pull ALL of their data again.
                    So if the repair was run on 5 users and each user profile is 10GB, workfolders on all of their clients will try to pull the 10GB all over again totalling over 50GB as a minimum depending how many devices they have
                    #>
            } else {
                changeSubfolderPermissions
                setDomainAdmin
            }
        } else {
            changeSubfolderPermissions
            setDomainAdmin
        }
    }
}

#Starting the workfolders service now that all the changes have been made
    if ($null -eq $SPECIFICUSER) {Start-Service "Windows Sync Share"}
