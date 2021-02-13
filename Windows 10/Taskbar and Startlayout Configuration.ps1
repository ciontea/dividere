<# To create and use this .xml
            Step 1: Configure the start menu how you want it to look
            Step 2: In PowerShell, run command below
                Export-StartLayout –path C:\Temp\StartMenuLayout.xml
            Step 3: If you want to add some other applications without doing this but need the ID of the app, run these commands
                Get-StartApps | Sort-Object Name
                Get-StartApps | Where-Object Name -like "*Word*" | Sort-Object Name
            Step 4: Create a GPO > User Configuration or Computer Configuration > Administrative Templates >Start Menu and Taskbar
            old.Step 4: Do not use this method to import the xml as the taskbar will always be forced and no one can change it (refreshes on logout/login)
                Import-StartLayout -LayoutPath "C:\temp\layout.xml" -MountPath C:\
            Step 5: Teams icon will have to be created in %ALLUSERSPROFILE% instead of %APPDATA% or the layout.xml will not apply properly for teams as that shortcut gets created only after the layout gets applied.
                I have created the shortcut in the final menu option post imaging
        #>
        $taskbarlocation = "C:\temp\layout.xml"
        '<?xml version="1.0" encoding="utf-8"?>
        <LayoutModificationTemplate
          xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
          xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
          xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
          xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
          Version="1">
          
          <LayoutOptions StartTileGroupCellWidth="6" />
          <DefaultLayoutOverride LayoutCustomizationRestrictionType="OnlySpecifiedGroups">
            <StartLayoutCollection>
              <defaultlayout:StartLayout GroupCellWidth="6">
                <start:Group Name="Tools">
                  <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
                  <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" />
                  <start:DesktopApplicationTile Size="2x2" Column="4" Row="4" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
                  <start:DesktopApplicationTile Size="2x2" Column="0" Row="4" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk" />
                  <start:Tile Size="2x2" Column="2" Row="4" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
                  <start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Excel.lnk" />
                  <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Word.lnk" />
                  <start:DesktopApplicationTile Size="2x2" Column="4" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Outlook.lnk" />
                  <start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
                </start:Group>
              </defaultlayout:StartLayout>
            </StartLayoutCollection>
          </DefaultLayoutOverride>
        
          <CustomTaskbarLayoutCollection PinListPlacement="Replace">
            <defaultlayout:TaskbarLayout>
              <taskbar:TaskbarPinList>
                <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
                <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
                <taskbar:UWA AppUserModelID="Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" />
                <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Outlook.lnk" />
                <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Word.lnk" />
                <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Excel.lnk" />
                <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk" /> 
              </taskbar:TaskbarPinList>
            </defaultlayout:TaskbarLayout>
          </CustomTaskbarLayoutCollection>
        </LayoutModificationTemplate>
        
        <!--NOTES:
          -You can add any notes you need here
        -->' | Out-File $taskbarlocation -Encoding utf8
