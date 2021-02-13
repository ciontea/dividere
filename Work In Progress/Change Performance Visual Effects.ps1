<#
Purpose: Change settings and/or defaults for Windows 10 settings > System > About > Advanced System Settings > Advanced tab > Performance Settings > Visual Effects tab

https://www.tenforums.com/tutorials/6377-change-visual-effects-settings-windows-10-a.html
https://www.reddit.com/r/Citrix/comments/gt2lo1/changing_the_visual_effects_userpreferencesmask/
https://social.technet.microsoft.com/Forums/windowsserver/en-US/73d72328-38ed-4abe-a65d-83aaad0f9047/adjust-for-best-performance?forum=winserverpowershell
https://www.sevenforums.com/tutorials/1908-visual-effects-settings-change.html?filter

OTHER SETTINGS
Disable desktop composition
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"CompositionPolicy"=0

Enable transparent glass
[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"ColorizationOpaqueBlend"=0
#>

#Setting the Visual Effects option to Custom (Mandatory)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3

############ Table of settings (Windows 10 setting name = Registry setting name). * Means Chris Deorajh wants this to be enabled and the rest to be disabled ############
#Animate controls and elements inside windows (usermask)
#Animate windows when minimizing and maximizing
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
#Animations in the taskbar
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0
#*Enable Peek
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisablePreviewDesktop" -Value 0
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisablePreviewDesktop"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 1
#Fase or slide menus into view
#Fade or slide ToolTips into view
#Fade out menu items after clicking
#Save taskbar thumbnail previews
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnails" -Value 1 #This is for "Disable Explorer Thumbnails (All Users)"
#*Show shadows under mouse pointer
#Show shadows under windows
#*Show thumbnails instead of icons
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0
#*Show translucent selection rectangle
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 1
#*Show window contents while dragging
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 1
#Slide open combo boxes
#*Smooth edges of screen fonts
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 1
#Smooth-scroll list boxes
#*Use drop shadows for icon labels on the desktop
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 1

#Setting all the custom Visual Effect options in one go (this doesn't seem to work however)
$regParentPaths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")
$registryEnable = @("DWMAeroPeekEnabled","CursorShadow","ThumbnailsOrIcon","ListviewAlphaSelect","DragFullWindows","FontSmoothing","ListviewShadow")
$registryDisable = @("ControlAnimations","AnimateMinMax","TaskbarAnimations","MenuAnimation","TooltipAnimation","SelectionFade","DWMSaveThumbnailEnabled","DropShadow","ComboBoxAnimation","ListBoxSmoothScrolling")

foreach ($path in $regParentPaths) {
    foreach ($item in $registryEnable) {
        Set-ItemProperty -Path "$path\$item" -Name "CheckedValue" -Value 1
        Set-ItemProperty -Path "$path\$item" -Name "DefaultValue" -Value 1
    }
    foreach ($item in $registryDisable) {
        Set-ItemProperty -Path "$path\$item" -Name "CheckedValue" -Value 0
        Set-ItemProperty -Path "$path\$item" -Name "DefaultValue" -Value 0
    }    
}

#Restart Themes Service for changes take effect
net stop themes
net start themes
