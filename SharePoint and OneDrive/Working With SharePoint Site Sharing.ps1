#Check sharing state
Get-SPOSite | Select-Object Url, SharingCapability

#Disable sharing
Set-SPOSite -Identity contoso.sharepoint.com/sites/firstSite -SharingCapability Disabled
