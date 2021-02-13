#Purpose: Sets the default application defaults for each person's first login on the computer
if (!(Test-Path "C:\temp\Scripts")) {New-Item -ItemType Directory -Path "C:\temp\Scripts"}
        <# To create the Default Apps XML, run the commands below in administrative PowerShell
            if ((Test-Path "C:\temp") -eq $false) {New-Item -ItemType Directory -Path "C:\Temp"}
            Dism.exe /online /Export-DefaultAppAssociations:C:\Temp\DefaultAssociations.xml
            Start-Process "C:\Temp"
            
            Full Name = "Chrome", "Firefox", "VLC media player", "Outlook", "Mail", etc.
        #>
        $defaultappslocation = "C:\Windows\System32\DefaultAssociations.xml"
        '<?xml version="1.0" encoding="UTF-8"?>
        <DefaultAssociations>
            <Association Identifier=".avi" ProgId="VLC.avi" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".divx" ProgId="VLC.divx" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".flac" ProgId="VLC.flac" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".m4a" ProgId="VLC.m4a" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mkv" ProgId="VLC.mkv" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mov" ProgId="VLC.mov" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mp3" ProgId="VLC.mp3" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mp4" ProgId="VLC.mp4" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mp4v" ProgId="VLC.mp4v" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mpeg" ProgId="VLC.mpeg" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".mpg" ProgId="VLC.mpg" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".ogg" ProgId="VLC.ogg" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".ogm" ProgId="VLC.ogm" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".vlc" ProgId="VLC.vlc" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".vob" ProgId="VLC.vob" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".wav" ProgId="VLC.wav" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".wma" ProgId="VLC.wma" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".wmv" ProgId="VLC.wmv" ApplicationName="Media Player of Choice Full Name" />
            <Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Browser of Choice Full Name" />
            <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Browser of Choice Full Name" />
            <Association Identifier=".ics" ProgId="Outlook.File.ics.15" ApplicationName="Email Client of Choice Full Name" />
            <Association Identifier=".pdf" ProgId="AcroExch.Document.DC" ApplicationName="Adobe Acrobat Reader DC" />
            <Association Identifier="ftp" ProgId="ChromeHTML" ApplicationName="Browser of Choice Full Name" />
            <Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Browser of Choice Full Name" />
            <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Browser of Choice Full Name" />
            <Association Identifier="mailto" ProgId="Outlook.URL.mailto.15" ApplicationName="Email Client of Choice Full Name" />
            <Association Identifier="WEBCAL" ProgId="Outlook.URL.webcal.15" ApplicationName="Email Client of Choice Full Name" />
        </DefaultAssociations>' | Out-File $defaultappslocation -Encoding utf8
        <#Old way of doing it: Enforces the default apps on each logon so if you changed the default browser to Firefox, it will change back to Chrome on next logon if that is the default in the xml file
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DefaultAssociationsConfiguration" -Value $defaultappslocation -PropertyType String -Force | Out-Null
            And then in login - interactive
                ################################################################### Default Apps ###################################################################
                #Steps below will only set the default apps for the first contoso user to log into the computer
                if ((whoami) -like "*contoso*") {
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DefaultAssociationsConfiguration" -Force
                }
        #>
        dism /online /Import-DefaultAppAssociations:$defaultappslocation #The default application associations will be applied for each user during their first logon. The rest of the default associations are done through GPO
