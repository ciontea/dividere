<#
Pre-req to connect to Office 365 via PowerShell is the command below
    Install-Module -Name MSOnline

Purpose of Script: 
It is primarily intended to delete a spam email (or all emails from a bad sender) from all Office 365 mailboxes without needing to get the end-users involved or have them notified. This helps in case spam gets through your spam filter and you need to delete a malicious email quickly from all mailboxes before someone opens the attachment(s) or link(s)
#>


#The only variables you will need to change for this script
$smtpserver = "10.0.0.0" #Use IP Address or FQDN of SMTP server in the quotation marks
$emailrecipient = "example@domain.com" #Changing the default address that the email will send to containing the content search query that was just run

#Declaring all needed functions
function inputnote {
    Write-Host "Notes:" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host 'If subject has special characters such as $ and ", search results may not work as expected or at all' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "If subject is too generic such as 'help', use the sender's email address instead" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "You can filter by subject only, sender only, or both depending on situation" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "Content search name should not contain special characters so keep it simple" -ForegroundColor Yellow -BackgroundColor Black
    "","" | Write-Host
}
function exit365 {
    Remove-PSSession $Session
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
    Start-Process "https://protection.office.com/contentsearchbeta?ContentOnly=1"
}
function buildquery {
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
        Set-Variable -Name "subject" -Value $null -Scope Global
        Set-Variable -Name "from" -Value $null -Scope Global
        Set-Variable -Name "searchname" -Value $null -Scope Global
        Set-Variable -Name "confirm" -Value $null -Scope Global
        Set-Variable -Name "ComplianceSearchAction" -Value $null -Scope Global
        Set-Variable -Name "quit" -Value $true -Scope Global
        Set-Variable -Name "purge" -Value $true -Scope Global
        Set-Variable -Name "delete" -Value $null -Scope Global
        Set-Variable -Name "deletesearch" -Value $null -Scope Global
        Set-Variable -Name "preview" -Value $null -Scope Global
        Set-Variable -Name "previewselected" -Value $null -Scope Global
        Set-Variable -Name "newsubject" -Value $null -Scope Global
        Set-Variable -Name "newfrom" -Value $null -Scope Global
        Set-Variable -Name "newsearchname" -Value $null -Scope Global
        Set-Variable -Name "newquery" -Value $null -Scope Global
        Set-Variable -Name "ticket" -Value $null -Scope Global
        Set-Variable -Name "ticketselected" -Value $null -Scope Global
        Set-Variable -Name "answer" -Value $null -Scope Global
    } elseif ($answer -eq "n") {
        exit365
    } else {
        Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
    }
}


<################################################################################################################
Script Start
################################################################################################################>

#Connecting to Security and Compliance Office 365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
$UserCredential = $null #Clearing out your credentials now that you're connected
"","" | Write-Host

#Starting the loop for the entire script in case you want to remove multiple queries
Set-Variable -Name "repeat" -Value $true -Scope Global

while ($repeat) {
    $quit = $null
    $purge = $null
    while ($confirm -ne "y") {
        #Gathering Information from user about the spam email and making sure it is correct
        inputnote
        Set-Variable -Name "subject" -Value (Read-Host -Prompt "What is the email subject?") -Scope Global
        Write-Host "For domain do not include the @ symbol, instead type 'microsoft.com'" -ForegroundColor Yellow -BackgroundColor Black
        Set-Variable -Name "from" -Value (Read-Host -Prompt "What is the sender's email address?") -Scope Global
        Set-Variable -Name "searchname" -Value (Read-Host -Prompt "What is the content search name?") -Scope Global
        
        #Creating a summary page of the changes
        Clear-Host
        Write-Host "Please make sure the information below is correct before continuing"
        Write-Host "-" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "Subject:               $subject"
        Write-Host "From:                  $from"
        Write-Host "Content Search Name:   $searchname"
        Write-Host "-" -ForegroundColor Yellow -BackgroundColor Black

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
    $confirm = $null #Clearing out the variable because it is used by the function called 'preview'
    
    #Starting the content search
    New-ComplianceSearch -Name $searchname -ExchangeLocation All -ContentMatchQuery $query -AllowNotFoundExchangeLocationsEnabled $false
    Start-ComplianceSearch -Identity $searchname
    Set-Variable -Name "ComplianceSearchAction" -Value ($searchname + "_Preview") -Scope Global
    
    #Checking status of the search before deleting and then deleting when ready
    while ($delete -ne "y") {
        while ($previewselected -ne $true) {
            "","" | Write-Host
            Write-Host "PowerShell      = Shows the search results in plaintext in PowerShell (hard to read)" -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "Online          = Recommended option to view the search results through the Security and Compliance web portal" -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "Both            = Performs option 'PowerShell' and 'Online'" -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "Quick           = Just checking the status of the search" -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "ChangeQuery     = Allows you to change the subject or from address" -ForegroundColor Yellow -BackgroundColor Black
            "","" | Write-Host
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

                    #Moving the new values to the old variables if they've been changed
                    if (($newsubject -eq $subject) -or ($newsubject -eq "") -or ($null -eq $newsubject)) {
                        #Do nothing since nothing has changed
                    } elseif ($newsubject -eq "Clear") {
                        Set-Variable -Name "subject" -Value $null -Scope Global
                        Set-Variable -Name "newsubject" -Value $null -Scope Global
                    } else {
                        Set-Variable -Name "subject" -Value $newsubject -Scope Global
                    }
                    if (($newfrom -eq $from) -or ($newfrom -eq "") -or ($null -eq $newfrom)) {
                        #Do nothing since nothing has changed
                    } elseif ($newfrom -eq "Clear") {
                        Set-Variable -Name "from" -Value $newsubject -Scope Global
                        Set-Variable -Name "newfrom" -Value $newsubject -Scope Global
                    } else {
                        Set-Variable -Name "from" -Value $newfrom -Scope Global
                    }

                    buildquery

                    #Creating a summary page of the changes
                    Clear-Host
                    Write-Host "Please make sure the information below is correct before continuing"
                    Write-Host "-" -ForegroundColor Yellow -BackgroundColor Black
                    Write-Host "Subject:               $newsubject"
                    Write-Host "From:                  $newfrom"
                    Write-Host "Content Search Name:   $newsearchname"
                    Write-Host "-" -ForegroundColor Yellow -BackgroundColor Black
    
                    $confirm = Read-Host -Prompt "Is the above correct? (y, n, exit)"
                    if ($confirm -eq "exit") {
                        delsearchexit
                    } elseif ($confirm -eq "y") {
                        if (($newsearchname -eq $searchname) -or ($newsearchname -eq "") -or ($null -eq $newsearchname)) {
                            #Only changing the query since the content search name has remained the same
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
        $delete = Read-Host -Prompt "Ready to delete the emails? (y, n, exit)"
        if ($delete -eq "y") {
            New-ComplianceSearchAction -SearchName $searchname -Purge -PurgeType HardDelete
        } elseif ($delete -eq "n") {
            $previewselected = $false #This allows the previous loop to restart
            $confirm = $null
        } elseif ($delete -eq "exit") {
            delsearchexit
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
    
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
    
    #Removing content search as it should no longer be needed now if the purge is complete (unless you specify you want to keep it)
    while ($purge -ne "y") {
        $purge = Read-Host "Have the emails been deleted from the mailboxes? (y or n)"
    
        if ($purge -eq "y") {
            while ($quit -ne $true) {
                $deletesearch = Read-Host -Prompt "Would you like to remove the content search? (y or n)"
                
                if ($deletesearch -eq "y") {
                    Remove-ComplianceSearch -Identity $searchname
                    startover
                } elseif ($deletesearch -eq "n") {
                    startover
                } else {
                    Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
                }
            }
        } elseif ($purge -eq "n") {
            Start-Sleep -Seconds 6
            Get-ComplianceSearch -Identity $searchname
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Black
        }
    }
}