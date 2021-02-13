function mapdrives {
    $usernamematch = $false
    $passwordmatch = $false
    $sDrive = Get-PSDrive | Where-Object Name -eq "s"
    $tDrive = Get-PSDrive | Where-Object Name -eq "t"

    if ((!($domainUser)) -and (($null -ne $serverS) -or ($null -ne $serverT))) {
        if (($null -eq $sDrive) -or ($null -eq $tDrive)) {
            #Grabbing username and making sure it is correct
                Do {
                    Write-Host "Please type in your AD account for the script to have access to srv07missfs, srv03misspm and srv05missgm"
                    Write-Host "(Preferably your domain admin so you have the access needed)"
                    $username = Read-Host -Prompt "AD Username"
                    $fullusername = "contoso\" + $username
                    $confirmusername = Read-Host -Prompt "Confirm AD Username"

                    #Checking to see if the usernames match
                    if ($username -eq $confirmusername) {
                        $usernamematch = $true #Stops the loop since the usernames match
                    } else {
                        Write-Host "Usernames do not match!"
                    }
                } Until ($usernamematch)            

            #Grabbing password and making sure it is correct
                Do {
                    #Asking the user for their password
                    $securepassword = Read-Host -Prompt "AD Password" -AsSecureString
                    $confirmpassword = Read-Host -Prompt "Confirm AD Password" -AsSecureString

                    #Converting $securepassword to plaintext
                    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securepassword)
                    $PlainsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)                

                    #Converting $confirmpassword to plaintext. This may seem like a duplicate step but it is needed to make sure that the user typed in the correct password. It is compared against $securepassword
                    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmpassword)
                    $PlainconfirmPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

                    #Checking to see if the passwords match
                    if ($PlainsecurePassword -eq $PlainconfirmPassword) {
                        $passwordmatch = $true #Stops the loop since the passwords match

                        #Clearing out the plaintext password from memory so it cannot be accessed again/anymore
                        $PlainsecurePassword = $null
                        $PlainconfirmPassword = $null
                        $PlainsecurePassword = "1"
                        $PlainconfirmPassword = "1"
                    } else {
                        Write-Host "Passwords do not match"
                    }
                } Until ($passwordmatch)
            
            #Converting username and password to a PSCredential
                $pscredential = New-Object System.Management.Automation.PSCredential($fullusername,$securepassword)

            #Mapping the Drives
                New-PSDrive -Name "s" -Root $serverS -Credential $pscredential -Persist -PSProvider "FileSystem" -Scope Global
                New-PSDrive -Name "t" -Root $serverT -Credential $pscredential -Persist -PSProvider "FileSystem" -Scope Global

            #Clearing the password from memory after finished mapping drives
                $securepassword = $null
                $pscredential = $null
                $securepassword = "1"
                $pscredential = "1"
        }
    }
}
function deletemapdrives {
    #Removing the mappings
    Remove-PSDrive -Name s
    Remove-PSDrive -Name t
}
