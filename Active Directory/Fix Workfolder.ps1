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

########################## Functions Needed ##########################
function setdomainadmin {
    $accessrule = @()
    Write-Host "$($acl.PSChildName) Folder does not have an associated AD account therefore access will be restricted to only Domain Admins" -BackgroundColor Black -ForegroundColor Yellow
    $aclowner = "Domain Admins"
    #Disabling inheritance on the folder. To enable inheritance again, flip this section to $false,$true instead of $true,$false
    $acl.SetAccessRuleProtection($true,$false)
    #Remove all ACL permissions now that the inherited permissions are gone
    $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
    #Setting the owner of the folder
    $owner = New-Object System.Security.Principal.Ntaccount("$DomainName\$aclowner")
    $acl.SetOwner($owner)
    #Adding the correct permissions. The order of the command below can be found by running $acl.access which should show identity, fileSystemRights, inheritanceFlags, propagationFlags (not needed so leave blank), type
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\$aclowner","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\LOCAL SERVICE","FullControl","ContainerInherit, ObjectInherit","None","Deny")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\Authenticated Users","AppendData, ReadAndExecute, ChangePermissions, Synchronize","ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","ContainerInherit, ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\Domain Users","AppendData, ReadAndExecute, ChangePermissions, Synchronize","ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","AppendData, ReadAndExecute, ChangePermissions, Synchronize","ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\DATA_RW","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    foreach ($rule in $accessrule) {
        $acl.SetAccessRule($rule)
    }
    #Making the permissions changes
    $acl | Set-Acl $acl.path
}
function setdomainuser {
    $accessrule = @()
    Write-Host "The owner of folder $($acl.PSChildName) is AD User $aclowner"
    #Disabling inheritance on the folder. To enable inheritance again, flip this section to $false,$true instead of $true,$false
    $acl.SetAccessRuleProtection($true,$false)
    #Remove all ACL permissions now that the inherited permissions are gone
    $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
    #Setting the owner of the folder
    $owner = New-Object System.Security.Principal.Ntaccount("$DomainName\$aclowner")
    $acl.SetOwner($owner)
    #Adding the correct permissions. The order of the command below can be found by running $acl.access which should show identity, fileSystemRights, inheritanceFlags, propagationFlags (not needed so leave blank), type
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\$aclowner","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\LOCAL SERVICE","FullControl","ContainerInherit, ObjectInherit","None","Deny")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\Authenticated Users","AppendData, ReadAndExecute, ChangePermissions, Synchronize","ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","ContainerInherit, ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\Domain Admins","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\Domain Users","AppendData, ReadAndExecute, ChangePermissions, Synchronize","ObjectInherit","InheritOnly","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit, ObjectInherit","None","Allow")
    $accessrule += New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","AppendData, ReadAndExecute, ChangePermissions, Synchronize","ObjectInherit","InheritOnly","Allow")
    foreach ($rule in $accessrule) {
        $acl.SetAccessRule($rule)
    }
    #Making the permissions changes
    $acl | Set-Acl $acl.path
}

########################## Grabbing the ACL (permissions) and AD user information from the folders ##########################
    $userfolders = Get-ChildItem $workfolderspath -Directory
    $exceptionfolders = @()
    $userfolderpermissions = @()

    foreach ($folder in $userfolders) {
        $continue = $null
        foreach ($exception in $manualexceptions) {
            if ($folder.Name -like "*$exception*") {
                $continue = $false
            }
        }
        if ($continue -ne $false) {
            try {
                $userfolderpermissions += Get-Acl "$workfolderspath\$folder"
            } catch {
                $exceptionfolders += $folder
            }
        }
    }
    $exceptionfolders += $manualexceptions
    foreach ($exception in $exceptionfolders) {
        Write-Host "$exception folder's permissions will not be changed or you do not have permissions to this folder" -BackgroundColor Black -ForegroundColor Yellow
    }

########################## Backing up the current permissions to a csv if a rollback is needed ##########################
#VERY IMPORTANT: This does not create a record of all NTFS settings but only the ones we require
#Creating the folder for the backup if not already created
try {
    if (!(Test-Path $exportpath)) {New-Item -ItemType Directory -Path $exportpath}
} catch {
    New-Item -ItemType Directory -Path $exportpath
}

for ($i = 0; $i -lt ($acl.access).count; $i++) {
    $ruleHash = $null
    $ruleHash = [ordered]@{
        PSPath                          = $acl.PSPath
        PSParentPath                    = $acl.PSParentPath
        PSChildName                     = $acl.PSChildName
        "Access \ IdentityReference"    = $acl.Access.IdentityReference.Value[$i]
        "Access \ FileSystemRights"     = $acl.Access.FileSystemRights[$i]
        "Access \ AccessControlType"    = $acl.Access.AccessControlType[$i]
        "Access \ IsInherited"          = $acl.Access.IsInherited[$i]
        "Access \ InheritanceFlags"     = $acl.Access.InheritanceFlags[$i]
        "Access \ PropagationFlags"     = $acl.Access.PropagationFlags[$i]
        Owner                           = $acl.Owner
        Path                            = $acl.Path
        Sddl                            = $acl.Sddl
    }
    $ruleObject = New-Object PSObject -Property $ruleHash
    $ruleObject | Export-Csv "$exportpath\User Folder Permissions.csv" -NoTypeInformation -Append
}

########################## Making the required changes ##########################
foreach ($acl in $userfolderpermissions) {
    $continue = $null
    $hasowner = $null

    foreach ($exception in $manualexceptions) {
        if ($exception -like $acl.PSChildName) {
            $continue = $false
        }
    }

    if ($continue -ne $false) {
        if ($acl.Path -notlike "*.OLD*") {    
            <# NEED TO ADD SECTION for if the user no longer has an AD account but still has a folder, only domain admins should have access and restrict it to domain admins only#>
            #Adding the permissions and disabling inheritence on all folders
            $aclowner = @()    
            
            foreach ($aduser in $adusers) {
                if ($aduser.SamAccountName -like $acl.PSChildName) {
                    $hasowner = $true
                    $aclowner = $aduser.SamAccountName
                }
            }
            if ($hasowner) {
                setdomainuser
            } else {
                setdomainadmin
            }
        } else {
            setdomainadmin
        }
    }
}
