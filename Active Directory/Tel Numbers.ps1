<#
    Property Mobile                         Location in ADUC Telephone Tab > Cell Phone     Example XXX-XXX-XXXX
    Property (HomePhone or AAD.HomePhone)   Location in ADUC Telephone Tab > Home Phone     Example XXX-XXX-XXXX Ext: XXXX
    Property OfficePhone                    Location in ADUC General Tab > Phone Number     Example XXX-XXX-XXXX
    Property Mail                           Location in ADUC General Tab > Email            Example email@domain.com	
#>

#To find numbers when you know certain parts of it
Get-ADUser -Filter {officephone -like "647*"} -Properties OfficePhone | Select-Object Name, OfficePhone

#Find info for specific users
$users = @("Bob George", "George Bob")
$filter = 'Name -like "' + $user + '"'

foreach ($user in $users) {
    Get-ADUser -Filter $filter -Properties Mobile, OfficePhone, HomePhone, Mail | Select-Object Name, Mobile, OfficePhone, HomePhone, Mail | Sort-Object Name
}

#Get the members of an Active Directory security group and return their user object with the mobile property
Get-ADGroupMember $groupname | Get-ADUser -Properties mobile
