<#
	PRE REQs
	1. Exchange Online Remote PowerShell Module
		a. Steps b and c below ONLY WORK IN INTERNET EXPLORER
		b. Open the Exchange admin center (EAC) for your Exchange Online organization. For instructions, see Exchange admin center in Exchange Online.
		c. In the EAC, go to Hybrid > Setup and click the appropriate Configure button to download the Exchange Online Remote PowerShell Module for multi-factor authentication
	2. From Administrative PowerShell, run the commands below
		if (!(Get-InstalledModule -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue)) {Install-Module -Name ExchangeOnlineManagement}

Purpose of Script:
It is primarily intended to delete a spam email (or all emails from a bad sender) from all Office 365 mailboxes without needing to get the end-users involved or have them notified.
This helps in case spam gets through your spam filter and you need to delete a malicious email quickly from all mailboxes before someone opens the attachment(s) or link(s).
#>


#The only variables you will need to change for this script
$smtpserver = "xxx.xxx.xxx.xxx" #Use IP Address or FQDN of SMTP server in the quotation marks
$emailrecipient = "support@contoso.com" #Changing the default address that the email will send to containing the content search query that was just run

#Declaring all needed functions
function inputnote {
    "Notes:",
    ' -If subject has special characters such as $ and ", search results may not work as expected or at all',
    " -If subject is too generic such as 'help', use the sender's email address instead",
    " -You can filter by subject only, sender only, or both depending on situation",
    " -Content search name should not contain special characters so keep it simple",
    "","" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
}
function exit365 {
    Get-PSSession | Remove-PSSession
    Exit
}
function powershellpreview {
    Write-Host "Please wait 45 seconds for results" -ForegroundColor Yellow -BackgroundColor Black
    Start-Sleep -Seconds 45
    New-ComplianceSearchAction -SearchName $searchname -Preview
    Get-ComplianceSearchAction -Identity $ComplianceSearchAction | Format-List -Property Results
}
function launchwebsite {
    Start-Sleep -Seconds 2
    Start-Process "https://compliance.microsoft.com/contentsearch"
}
function buildquery {
    #For more ideas here https://docs.microsoft.com/en-us/microsoft-365/compliance/keyword-queries-and-search-conditions?view=o365-worldwide
    if (($null -eq $subject) -or ($subject -eq "")) {
        $from = '(From=' + $from + ')'
        Set-Variable -Name "query" -Value $from -Scope Global
    } elseif (($null -eq $from) -or ($from -eq "")) {
        $subject = '(SubjectTitle="' + $subject + '")'
        Set-Variable -Name "query" -Value $subject -Scope Global
    } else {
        $subject = '(SubjectTitle="' + $subject + '")'
        $from = '(From=' + $from + ')'
        Set-Variable -Name "query" -Value ($subject + " AND " + $from) -Scope Global
    }
}
function delsearchexit {
    while ($quit -ne $true) {
        $deletesearch = Read-Host -Prompt "Would you like to remove the content search? (y or n)"
        
        if ($deletesearch -eq "y") {
            Remove-ComplianceSearch -Identity $searchname
            exit365
        } elseif ($deletesearch -eq "n") {
            exit365
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
}
function startover {
    $answer = Read-Host -Prompt "Would you like to start over? (y or n)"

    if ($answer -eq "y") {
        #Clearing all the variables so there are no issues
        Set-Variable -Name "ComplianceSearchAction", "newsubject", "newfrom", "newsearchname", "newquery" -Value $null -Scope Global
    } elseif ($answer -eq "n") {
        exit365
    } else {
        Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
    }
}
function summarypage {
    Clear-Host
    "Please make sure the information below is correct before continuing", "-" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    if ($null -eq $newsubject) {
        "Subject:               $subject" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    } else {
        "Subject:               $newsubject" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    }
    if ($null -eq $newfrom) {
        "From:                  $from" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    } else {
        "From:                  $newfrom" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    }
    if ($null -eq $newsearchname) {
        "Content Search Name:   $searchname" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    } else {
        "Content Search Name:   $newsearchname" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
    }
    "-" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
}

<######################################################## Script Start ########################################################>
#Connecting to Security and Compliance - Office 365
$getChildItemSplat = @{
    Path = "$Env:LOCALAPPDATA\Apps\2.0\*\CreateExoPSSession.ps1"
    Recurse = $true
    ErrorAction = 'SilentlyContinue'
    Verbose = $false
}

$MFAExchangeModule = ((Get-ChildItem @getChildItemSplat | Select-Object -ExpandProperty Target -First 1).Replace("CreateExoPSSession.ps1", ""))

If ($null -eq $MFAExchangeModule) {
    Write-Error "The Exchange Online MFA Module was not found!
    https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps"
    continue
} Else {
    Write-Verbose "Importing Exchange MFA Module (Required)"
    . "$MFAExchangeModule\CreateExoPSSession.ps1"
    Connect-IPPSSession
}

#Starting the loop for the entire script in case you want to remove multiple queries
Set-Variable -Name "repeat" -Value $true -Scope Global

while ($repeat) {
    while ($confirm -ne "y") {
        #Gathering Information from user about the spam email and making sure it is correct
        inputnote
        Set-Variable -Name "subject" -Value (Read-Host -Prompt "What is the email subject?") -Scope Global
        Write-Host "For domain do not include the @ symbol, instead type 'microsoft.com'" -ForegroundColor Yellow -BackgroundColor Black
        Set-Variable -Name "from" -Value (Read-Host -Prompt "What is the sender's email address?") -Scope Global
        Set-Variable -Name "searchname" -Value (Read-Host -Prompt "What is the content search name?") -Scope Global
        summarypage

        $confirm = Read-Host -Prompt "Is the above correct? (y, n, exit)"
        if ($confirm -eq "exit") {
            exit365
        } elseif ($confirm -eq "y") {
            buildquery
        } elseif ($confirm -eq "n") {
            #So it doesn't say invalid selection when typing 'n'
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
    $confirm = $null
    
    #Starting the content search
    New-ComplianceSearch -Name $searchname -ExchangeLocation All -ContentMatchQuery $query -AllowNotFoundExchangeLocationsEnabled $false
    Start-ComplianceSearch -Identity $searchname
    Set-Variable -Name "ComplianceSearchAction" -Value ($searchname + "_Preview") -Scope Global
    
    #Checking status of the search before deleting and then deleting when ready. If mistakes are made, the content search can be entirely re-built from this section of code
    while ($delete -ne "y") {
        while ($previewselected -ne $true) {
            "","",
            "PowerShell      = Shows the search results in plaintext in PowerShell (hard to read)",
            "Online          = Recommended option to view the search results through the Security and Compliance web portal",
            "Both            = Performs option 'PowerShell' and 'Online'",
            "Quick           = Just checking the status of the search",
            "ChangeQuery     = Allows you to change the subject or from address",
            "","" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
            $preview = Read-Host "Do you want to preview the emails? (powershell, online, both, quick, changequery, exit)"
            "","" | Write-Host
        
            if ($preview -eq "powershell") {
                powershellpreview
                $previewselected = $true
            } elseif ($preview -eq "online") {
                launchwebsite
                $previewselected = $true
            } elseif ($preview -eq "both") {
                launchwebsite
                powershellpreview
                $previewselected = $true
            } elseif ($preview -eq "changequery") {
                while ($confirm -ne "y") {
                    #Grabbing the new email information
                    inputnote
                    Set-Variable -Name "newsubject" -Value (Read-Host -Prompt "What is the new email subject? (Blank = No Changes, 'Clear' = Do not filter by subject)") -Scope Global
                    Write-Host "For domain do not include the @ symbol, instead type 'microsoft.com'" -ForegroundColor Yellow -BackgroundColor Black
                    Set-Variable -Name "newfrom" -Value (Read-Host -Prompt "What is the new sender's email address? (Blank = No Changes, 'Clear' = Do not filter by from address)") -Scope Global
                    Set-Variable -Name "newsearchname" -Value (Read-Host -Prompt "What is the new content search name? (Blank = No Changes)") -Scope Global

                    #Making the changes for the summary page to make sense before outputting to the user
                    if (($newsubject -eq $subject) -or ($newsubject -eq "") -or ($null -eq $newsubject)) {
                        Set-Variable -Name "newsubject" -Value $subject -Scope Global
                    } elseif ($newsubject -eq "Clear") {
                        Set-Variable -Name "subject" -Value $null -Scope Global
                        Set-Variable -Name "newsubject" -Value $null -Scope Global
                    } else {
                        Set-Variable -Name "subject" -Value $newsubject -Scope Global
                    }
                    if (($newfrom -eq $from) -or ($newfrom -eq "") -or ($null -eq $newfrom)) {
                        Set-Variable -Name "newfrom" -Value $from -Scope Global
                    } elseif ($newfrom -eq "Clear") {
                        Set-Variable -Name "from" -Value $null -Scope Global
                        Set-Variable -Name "newfrom" -Value $null -Scope Global
                    } else {
                        Set-Variable -Name "from" -Value $newfrom -Scope Global
                    }
                    if (($newsearchname -eq $searchname) -or ($newsearchname -eq "") -or ($null -eq $newsearchname)) {
                        Set-Variable -Name "newsearchname" -Value $searchname -Scope Global
                    }
                    summarypage
                    $confirm = Read-Host -Prompt "Is the above correct? (y, n, exit)"

                    if ($confirm -eq "exit") {
                        delsearchexit
                    } elseif ($confirm -eq "y") {
                        #Now that we have all the changes we want to make to the contentsearch, we can now build the query again
                        buildquery

                        #Making sure the user didn't want to change the name of the content search as well
                        if (($newsearchname -eq $searchname) -or ($newsearchname -eq "") -or ($null -eq $newsearchname)) {
                            #Only changing the query since the content search name has remained the same
                            Set-Variable -Name "newsearchname" -Value $searchname -Scope Global
                            Set-ComplianceSearch -Identity $searchname -ExchangeLocation All -ContentMatchQuery $query -AllowNotFoundExchangeLocationsEnabled $false
                            Start-ComplianceSearch -Identity $searchname
                        } else {
                            #Remove the old content search since the search name is changed
                            Remove-ComplianceSearch -Identity $searchname

                            #Create the new content search
                            Set-Variable -Name "searchname" -Value $newsearchname -Scope Global
                            Set-Variable -Name "ComplianceSearchAction" -Value ($searchname + "_Preview") -Scope Global
                            New-ComplianceSearch -Name $searchname -ExchangeLocation All -ContentMatchQuery $query -AllowNotFoundExchangeLocationsEnabled $false
                            Start-ComplianceSearch -Identity $searchname
                        }
                    } elseif ($confirm -eq "n") {
                        #So it doesn't say invalid selection when typing 'n'
                    } else {
                        Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
                    }
                }
                $confirm = $null
                #Not changing '$previewselected = $true' because I want it to loop back so you get the option to re-choose your preview options after changing the query
            } elseif ($preview -eq "exit") {
                    delsearchexit
            } elseif  ($preview -eq "quick") {
                Start-Sleep -Seconds 6
                Get-ComplianceSearch -Identity $searchname
                $previewselected = $true
            } else {
                Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
            }
            $confirm = $null
        }
        $preview, $previewselected = $null

        $delete = Read-Host -Prompt "Ready to delete the emails? (y, n, exit)"
        if ($delete -eq "y") {
            New-ComplianceSearchAction -SearchName $searchname -Purge -PurgeType HardDelete
        } elseif ($delete -eq "n") {
            #So it doesn't say invalid selection when typing 'n'. Also allows the loop to start over
        } elseif ($delete -eq "exit") {
            delsearchexit
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
    $delete = $null
    
    #Notifying administrators with the details of the query that just ran (can also be used to create a ticket for yourself)
    while ($ticketselected -ne $true) {
        Write-Host "Selecting 'email' will allow you to change the email from the built-in email which is currently set to" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "$email" -ForegroundColor Yellow -BackgroundColor Black
        $ticket = Read-Host -Prompt "Would you like to send an email for this content search? (y, n, email)"
    
        if ($ticket -eq "y") {
            #Grabbing your email address so the email is sent to the recipient from you (This is helpful if creating a ticket for yourself using this part of the script)
            $searcher = [adsisearcher]"(samaccountname=$env:USERNAME)"
            $email = $searcher.FindOne().Properties.mail

            Send-MailMessage -To $emailrecipient -From $email -Subject "Content Search has been run, see body for query completed" -Body $query -SmtpServer $smtpserver
            $ticketselected = $true
            
        } elseif ($ticket -eq "email") {
            while ($correctemail -ne "y") {
                $newemailrecipient = Read-Host -Prompt "Please enter a new email to send the query to"
                Write-Host "Is $newemailrecipient correct? (y or n)" -ForegroundColor Yellow -BackgroundColor Black
                $correctemail = Read-Host
    
                if ($correctemail -eq "y") {
                    $emailrecipient = $newemailrecipient
                    Write-Host "Now sending email to $emailrecipient. Please wait..."
                    Send-MailMessage -To $emailrecipient -From $email -Subject "Content Search has been run, see body for query completed" -Body $query -SmtpServer $smtpserver
                } elseif ($correctemail -eq "n") {
                    #So it doesn't say invalid selection when typing 'n'
                } else {
                    Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
                }
            }
            $ticketselected = $true
        } elseif ($ticket -eq "n") {
            break
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
    $ticket = $null
    $ticketselected = $null

    #Removing content search as it should no longer be needed now if the purge is complete (unless you specify you want to keep it)
    while ($purge -ne "y") {
        $emailspurgedaction = $searchname + "_Purge"
        Get-ComplianceSearchAction $emailspurgedaction #This will tell us if the purge has been completed
        $purge = Read-Host "Have the emails been deleted from the mailboxes? (y or n)"
    
        if ($purge -eq "y") {
            while ($quit -ne $true) {
                $deletesearch = Read-Host -Prompt "Would you like to remove the content search? (y or n)"
                
                if ($deletesearch -eq "y") {
                    Remove-ComplianceSearch -Identity $searchname
                    startover
                    $quit = $true
                    $purge = $true
                } elseif ($deletesearch -eq "n") {
                    startover
                    $quit = $true
                    $purge = $true
                } else {
                    Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
                }
            }
            $quit = $null
        } elseif ($purge -eq "n") {
            Start-Sleep -Seconds 6
            Get-ComplianceSearch -Identity $searchname
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
    $purge = $null
}
