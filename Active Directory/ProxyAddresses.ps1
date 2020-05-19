$exportpath = "C:\PowerShell Export\Proxyaddresses.csv "

#Finding Active Directory user's ProxyAddresses and exporting to CSV
Get-ADUser -Filter * -Properties proxyaddresses | Select-Object Name, @{L = "ProxyAddresses"; E = {$_.ProxyAddresses -join ";"}} | Export-Csv -Path $exportpath -NoTypeInformation

#Same as the above command except "smtp:"" is replaced with ";"
Get-ADUser -Filter * -Properties proxyaddresses | Select-Object Name, @{L = "ProxyAddresses"; E = {$_.ProxyAddresses -ireplace "smtp:","" -join ";"}} | Export-Csv -Path $exportpath -NoTypeInformation
