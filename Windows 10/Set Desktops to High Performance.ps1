function poweroptions {
    #Script will also disable USB selective suspend
        #To disable USB selective suspend on AC power (AC = Plugged in):
        Powercfg.exe -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
        #To disable USB selective suspend on DC power (DC = On Battery):
        Powercfg.exe -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

    #Determining if the computer being worked on is a desktop
    $computertype1 = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType #Needs to equal 1 for it to be a desktop
    $computertype2 = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes #Needs to equal 3 for it to be a desktop
        if ($computertype1 -eq 1) {
            $computertype1 = "Desktop"
        } elseif ($computertype1 -eq 2) {
            $computertype1 = "Mobile"
        } elseif ($computertype1 -eq 3) {
            $computertype1 = "Workstation"
        } elseif ($computertype1 -eq 4) {
            $computertype1 = "Enterprise Server"
        } elseif ($computertype1 -eq 5) {
            $computertype1 = "SOHO Server"
        } elseif ($computertype1 -eq 6) {
            $computertype1 = "SOHO Server - Appliance PC"
        } elseif ($computertype1 -eq 7) {
            $computertype1 = "SOHO Server - Performance Server"
        } elseif ($computertype1 -eq 8) {
            $computertype1 = "SOHO Server - Maximum"
        } else {
            $computertype1 = "Unknown"
        }

        if ($computertype2 -eq 3) {
            $computertype2 = "Desktop"
        } elseif ($computertype2 -eq 4) {
            $computertype2 = "Low Profile Desktop"
        } elseif ($computertype2 -eq 5) {
            $computertype2 = "Pizza Box"
        } elseif ($computertype2 -eq 6) {
            $computertype2 = "Mini Tower"
        } elseif ($computertype2 -eq 7) {
            $computertype2 = "Tower"
        } elseif ($computertype2 -eq 8) {
            $computertype2 = "Portable"
        } elseif ($computertype2 -eq 9) {
            $computertype2 = "Laptop"
        } elseif ($computertype2 -eq 10) {
            $computertype2 = "Notebook"
        } elseif ($computertype2 -eq 11) {
            $computertype2 = "Hand Held"
        } elseif ($computertype2 -eq 12) {
            $computertype2 = "Docking Station"
        } elseif ($computertype2 -eq 13) {
            $computertype2 = "All in One"
        } elseif ($computertype2 -eq 14) {
            $computertype2 = "Sub Notebook"
        } elseif ($computertype2 -eq 15) {
            $computertype2 = "Space-Saving"
        } elseif ($computertype2 -eq 16) {
            $computertype2 = "Lunch Box"
        } elseif ($computertype2 -eq 17) {
            $computertype2 = "Main System Chassis"
        } elseif ($computertype2 -eq 18) {
            $computertype2 = "Expansion Chassis"
        } elseif ($computertype2 -eq 19) {
            $computertype2 = "Sub Chassis"
        } elseif ($computertype2 -eq 20) {
            $computertype2 = "Bus Expansion Chassis"
        } elseif ($computertype2 -eq 21) {
            $computertype2 = "Peripheral Chassis"
        } elseif ($computertype2 -eq 22) {
            $computertype2 = "Storage Chassis"
        } elseif ($computertype2 -eq 23) {
            $computertype2 = "Rack Mount Chassis"
        } elseif ($computertype2 -eq 24) {
            $computertype2 = "Sealed-Case PC"
        } else {
            $computertype2 = "Unknown"
        }

    while ($finished -ne $true) {
        "", "", "If the computer is a desktop or you select the option force, the script will set the power plan to High Performance", "", "" | Write-Host -ForegroundColor Yellow -BackgroundColor Black
        $usercomputertype = Read-Host -Prompt "Is this computer a desktop to set the power options to high performance? (y, n, force)"

        if (($computertype1 -eq "Desktop") -and ($computertype2 -eq "Desktop") -and ($usercomputertype -eq "y")) {
            powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c #Changing the power plan to high performance
            $finished = $true
        } elseif ($usercomputertype -eq "force") {
            powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c #Changing the power plan to high performance
            $finished = $true
        } elseif (($computertype1 -eq "Desktop") -and ($computertype2 -eq "Desktop") -and ($usercomputertype -eq "n")) {
            "", "", "Are you sure this is not a desktop?", "Because the computer is saying it is a $computertype1 and/or a $computertype2" | Write-Host
            while ($confirm -ne $true) {
                $confirm = Read-Host -Prompt "Please confirm if this is a desktop (desktop, notdesktop, force)"
                if ($confirm -eq "desktop") {
                    powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c #Changing the power plan to high performance
                    $finished = $true
                    $confirm = $true
                } elseif ($confirm -eq "notdesktop") {
                    $finished = $true
                    $confirm = $true
                } elseif ($confirm -eq "force") {
                    powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c #Changing the power plan to high performance
                    $finished = $true
                    $confirm = $true
                } else {
                    Write-Host "Invalid Selection" -ForegroundColor Yellow -BackgroundColor Black
                }
            }
            $confirm = $null
        } elseif (($computertype1 -ne "Desktop") -and ($computertype2 -ne "Desktop") -and ($usercomputertype -eq "y")) {
            "", "", "Please verify the computer is a desktop because the computer is saying it is a $computertype1 and/or a $computertype2" | Write-Host
            while ($confirm -ne $true) {
                $confirm = Read-Host -Prompt "Please confirm if this is a desktop (desktop, notdesktop, force)"
                if ($confirm -eq "desktop") {
                    powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c #Changing the power plan to high performance
                    $finished = $true
                    $confirm = $true
                } elseif ($confirm -eq "notdesktop") {
                    $finished = $true
                    $confirm = $true
                } elseif ($confirm -eq "force") {
                    powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c #Changing the power plan to high performance
                    $finished = $true
                    $confirm = $true
                } else {
                    Write-Host "Invalid Selection" -ForegroundColor Yellow -BackgroundColor Black
                }
            }
            $confirm = $null
        } elseif (($computertype1 -ne "Desktop") -and ($computertype2 -ne "Desktop") -and ($usercomputertype -eq "n")) {
            $finished = $true
        } else {
            Write-Host "Invalid Selection" -ForegroundColor Yellow -BackgroundColor Black
        }
    }
    $finished = $null
}
