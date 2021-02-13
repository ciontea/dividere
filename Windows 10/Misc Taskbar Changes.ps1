                    #Removing Cortana Icon from taskbar
                        $cortanalocation = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                        if (Test-Path $cortanalocation) {
                            New-ItemProperty -Path $cortanalocation -Name "ShowCortanaButton" -Value 0 -PropertyType DWORD -Force | Out-Null
                        } else {
                            New-Item -Path $cortanalocation -Force
                            New-ItemProperty -Path $cortanalocation -Name "ShowCortanaButton" -Value 0 -PropertyType DWORD -Force | Out-Null
                        }
                    #Changing taskbar search bar to an icon
                        $searchbarlocation = "HKCU:Software\Microsoft\Windows\CurrentVersion\Search"
                        if (Test-Path $searchbarlocation) {
                            New-ItemProperty -Path $searchbarlocation -Name "SearchboxTaskbarMode" -Value 1 -PropertyType DWORD -Force | Out-Null
                                #A value of 2 will show the bar and 1 will show the icon only
                        } else {
                            New-Item -Path $searchbarlocation -Force
                            New-ItemProperty -Path $searchbarlocation -Name "SearchboxTaskbarMode" -Value 1 -PropertyType DWORD -Force | Out-Null
                        }
                    #Removing People Icon from taskbar
                        $peoplelocation = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
                        if (Test-Path $peoplelocation) {
                            New-ItemProperty -Path $peoplelocation -Name "PeopleBand" -Value 0 -PropertyType DWORD -Force | Out-Null
                        } else {
                            New-Item $peoplelocation -Force
                            New-ItemProperty -Path $peoplelocation -Name "PeopleBand" -Value 0 -PropertyType DWORD -Force | Out-Null
                        }
                    #Restarting the taskbar for the changes to take effect
                        Stop-Process -ProcessName explorer -Force
