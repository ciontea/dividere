<# Notes
-The class isn't really needed but helps when making as many icons as I do in my script
-I would also recommend avoid simple arrays to store these locations
#>

#Class used for the public desktop shortcuts
class Shortcuts {
    [string]$sp                 #shortcut path (where the shortcut is placed. Example: Shortcut will be placed on the desktop)
    [string]$tp                 #target path (where the shortcut will link to. Example: Desktop shortcut will link to notepad software)
    [string]$ico                #icon for desktop shortcut path
    [string]$rp                 #remove path of the old icon that is getting replaced if applicable
    [string]$ar                 #any arguments that the applications need to start up properly
}

#Initiating the software
$googlechromeshortcut = [Shortcuts]::new()
$firefoxshortcut = [Shortcuts]::new()

#Desktop icon can be as simple as this... (these values are just examples, do not actually use them)
$firefoxshortcut.sp = "$env:Public\Desktop\Firefox.lnk"
$firefoxshortcut.tp = "C:\Program Files (x86)\Firefox.exe"

#...Or as complex as this (these values are just examples, do not actually use them)
$googlechromeshortcut.sp = "$env:Public\Desktop\Google Chrome.lnk"
$googlechromeshortcut.tp = "C:\Program Files\Chrome.exe"
$googlechromeshortcut.ico = "C:\Images\Chrome.ico"
$googlechromeshortcut.rp = "C:\OldIconPath.lnk"
$googlechromeshortcut.ar = "-sampleargument 1234"

#Creating the array for all the shortcuts
$allshortcuts = @($firefoxshortcut, $googlechromeshortcut)

#Now to create the shortcuts
foreach ($short in $allshortcuts) {
    #Deleting the old desktop icon if it was created during install on the local user's desktop only
    if ($null -ne $short.rp) {
        if (Test-Path $short.rp) {Remove-Item -Path $shortcut.rp -Force}
    }

    #Creating the new icon
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($short.sp)
    $Shortcut.TargetPath = $short.tp
    if ($null -ne $short.ar) {$Shortcut.Arguments = $short.ar}
    if ($null -ne $short.ico) {$Shortcut.IconLocation = $short.ico}
    $Shortcut.Save()
}