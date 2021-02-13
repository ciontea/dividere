#If you run the command:
Remove-SPOSite -Identity https://contoso.sharepoint.com/sites/ACCIDENTALSITE -NoWait

<#
And get the error:
Remove-SPOSite : This site collection can't be deleted because it contains sites that are included in an eDiscovery
hold or retention policy.

Root Cause:
Please go to Office 365 portal > Security Compliance > Data governance > Retention > Here you will likely find a policy that has placed a lock on Office 365 groups or Teams, etc. that is associated to that link.

Example:
You create a retention policy to lock those resources from being deleted. You now create a new MS Team called "Accounting" which in turn creates an associated Office 365 group and a SharePoint link where it's documents and information will be stored. You delete this MS Team but the SharePoint link with all resources in that link will still exist and cannot be deleted because of the Retention lock
#>
