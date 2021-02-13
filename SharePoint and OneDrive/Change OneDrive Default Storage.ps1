
<#
Must read articles to understand this better
	1. https://docs.microsoft.com/en-us/onedrive/set-default-storage-space?redirectSourcePath=%252farticle%252fcec51d07-d7e0-42a3-b794-9c00ad0f0083
	2. https://docs.microsoft.com/en-us/office365/servicedescriptions/onedrive-for-business-service-description

This is a tenant wide setting that will increase storage quota for all users. When you need cloud storage for individual users beyond the initial 5 TB, admins can open a case with Microsoft technical support to request it. Additional cloud storage will be granted as follows:

When a user has filled their 5 TB of OneDrive storage to at least 90% capacity, Microsoft will increase your default storage space in OneDrive to up to 25 TB per user (admins may set a lower per user limit if they want to).

For any user that reaches at least 90% capacity of their 25 TB of OneDrive storage, additional cloud storage will be provided as 25 TB SharePoint team sites to individual users. Contact Microsoft technical support for information and assistance.

To change it
	• GUI (OneDrive Admin Portal)
		○ 1024 GB for 1 TB
		○ 5120 GB for 5 TB

To view a user's quota limit, you must view it through the OneDrive Admin Portal
#>

#Change the Quota
#$quota = 1048576 #for 1 TB
$quota = 5242880 #for 5 TB
Set-SPOTenant -OneDriveStorageQuota $quota

#Reset the quota back to default
Set-SPOSite -Identity "<user's OneDrive URL>" -StorageQuotaReset
