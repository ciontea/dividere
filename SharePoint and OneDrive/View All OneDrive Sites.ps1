<#

ALL URL's
Tenant
	• https://contoso.sharepoint.com
MS Teams
	• your-tenant.sharepoint.com/teams/groupname
OneDrive
https://contoso-my.sharepoint.com/personal/

#>

$onedrivesites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Select-Object  Url, SharingCapability | Sort-Object Url
