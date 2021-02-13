<#

ALL URL's
Tenant
	• https://contoso.sharepoint.com
MS Teams
	• your-tenant.sharepoint.com/teams/groupname
OneDrive
https://contoso-my.sharepoint.com/personal/

#>

$sites = Get-SPOSite | Select-Object Url, SharingCapability
