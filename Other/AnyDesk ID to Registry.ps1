<#
Pre-req: Must have a plan with AnyDesk that allows you to deploy the software through MSI

Scenario: This script is best added to your "Golden Image" to you will deploy to new computers and must be done per computer
Step 1: Modify the variables #admin, #output and $registrypath, then run this script to create the required PowerShell file and Task Schedule task
Step 2: Make sure Task Scheduler task is configured to your liking
Step 3: Go to your Asset Management Solution and make sure it scans the computers you now deploy for the path "HKLM:\Custom Software\AnyDesk\ID" and the value "ID"

Notes: You obviously don't have to place the AnyDesk ID in the registry, another solution is a text file but our asset mangement solution cannot scan text files unfortunately
#>

$admin = "Name of the account to use as a local admin on the computer. Example: MyLocalAdminUserName"
$output = "Where you want the PowerShell Script to output to. Example: C:\Scripts\AnyDesk.ps1"

'################################################################### AnyDesk ID in Registry ###################################################################
    #Putting the AnyDesk ID into a variable to use later on
        $registrypath = "HKLM:\Custom Software\AnyDesk\ID"
        $temp = findstr "ad.anynet.id=" "C:\ProgramData\AnyDesk\ad_XXXXXXXX_msi\system.conf"
        $anydeskid = $temp -replace "ad.anynet.id="
 
    #Adding the ID to the registry for Lansweeper to pick up on its daily scan
    If (Test-Path $registrypath){
        New-ItemProperty -Path $registrypath -Name "ID" -Value $anydeskid -PropertyType DWORD -Force | Out-Null
    } else {
        New-Item -Path $registrypath -Force | Out-Null
        New-ItemProperty -Path $registrypath -Name "ID" -Value $anydeskid -PropertyType DWORD -Force | Out-Null
    }' | Out-File $output -Encoding utf8
 
 
$Action = New-ScheduledTaskAction -Execute 'PowerShell' -Argument '-NonInteractive -NoProfile -ExecutionPolicy Bypass -File $output'
$Trigger = New-ScheduledTaskTrigger -AtLogOn
 
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "AnyDesk ID to Registry" -RunLevel Highest -User $admin
Write-Host "The Task Scheduler task has now been created but there are just a few tweaks that need to be made so please open it up now and make sure all settings are correct"
Write-Host "If the Task Scheduler commands failed, this means that it already exists and you will have to look at the script to make the changes manually to it"
Pause
