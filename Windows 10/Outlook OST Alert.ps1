                #Since the .ost starts causing general Outlook issues when it reaches past 50GB, the below code will email helpdesk when the .ost reaches our threshold
                #Script will check every 30 seconds

                #Changing Variables
                    $ostAlertSize = 45      #This is the size in GB (GigaBytes) of when the alert will trigger if the .ost is larger than what is specified in this variable
                    $smtpServer = "xxx.xxx.xxx.xxx"

                #Variables that do not change
                    $currentUser = [adsisearcher]"(samaccountname=$env:USERNAME)"
                    $currentUser = $currentuser.FindOne().Properties.mail
                    $currentComputer = $env:COMPUTERNAME
                    $ostPath = Get-ChildItem $env:LOCALAPPDATA\Microsoft\Outlook
                    $ostLogFile = "C:\temp\OST Last Checked Date.txt"
                    $ostLogFileCheck = Test-Path $ostLogFile
                    $currentDate = Get-Date -UFormat "%Y-%m-%d"

                #Checking the file sizes. I could limit this to files ending in .ost but it is better to just search them all for size
                    foreach ($file in $ostPath) {
                        $sizeFile = $file.length/1GB
                        if ($sizeFile -gt $ostAlertSize) {$ostAlert = $true}
                    }

                #Logging when the .ost sizes were last checked so we do not get multiple tickets in one day from the same user
                    if ($ostLogFileCheck) {
                        $loggedDate = Get-Content $ostLogFile

                        if ($loggedDate -ne $currentDate) {
                            Remove-Item -Path $ostLogFile -Force
                            New-Item -ItemType File -Path $ostLogFile -Value $currentDate
                            $newDayAlert = $true
                        }
                    } else {
                        New-Item -ItemType File -Path $ostLogFile -Value $currentDate -Force
                        $newDayAlert = $true
                    }

                #Sending the Alert
                    if ($ostAlert) {
                        if ($newDayAlert) {
                            do {
                                $computeron = Test-Connection -Cn $smtpServer -BufferSize 16 -Count 1 -ea 0 -quiet

                                if ($computeron) {
                                    $body = "$currentuser has at least one .ost that is larger than our currently set threshold of $ostAlertSize GB on the computer $currentComputer. Please re-create the profile(s)"
                                    Send-MailMessage -From $currentUser -To "alert@contoso.com" -Subject "OST too large" -Body $body -bodyasHTML -SmtpServer $smtpServer
                                }
                                Start-Sleep -Seconds 30 #So as not to flood the computer with ping requests
                            } while ($computeron -ne $true)
                        }
