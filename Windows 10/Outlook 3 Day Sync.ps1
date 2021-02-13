#Purpose: Outlook Cached mode defaults 1 year when setting it up. These registry keys will default 3 days instead but allows the user to change it on set up and even after the account has been set up
New-Item -Path "HKCU:\SOFTWARE\microsoft\office\16.0\outlook\Cached Mode"

#Both of the registry keys must be included below or it will not work
New-ItemProperty -Path "HKCU:\SOFTWARE\microsoft\office\16.0\outlook\Cached Mode" -Name "SyncWindowSettingDays" -Value 3 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKCU:\SOFTWARE\microsoft\office\16.0\outlook\Cached Mode" -Name "SyncWindowSetting" -Value 0 -PropertyType DWORD -Force | Out-Null
