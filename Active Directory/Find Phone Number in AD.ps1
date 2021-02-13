<#
    Property Mobile                         Location in ADUC Telephone Tab > Cell Phone     Example 647-xxx-xxxx
    Property MobilePhone                    Location in ADUC Telephone Tab > Cell Phone     Example 647-xxx-xxxx
        When you update Mobile or MobilePhone, they both get updated at the same time (think of them as being the exact same)
    Property (HomePhone or AAD.HomePhone)   Location in ADUC Telephone Tab > Home Phone     Example 905-xxx-xxxx Ext: xxx
    Property OfficePhone                    Location in ADUC General Tab > Phone Number     Example 647-xxx-xxxx (Can be cell phone or desk phone)
    Property Mail                           Location in ADUC General Tab > Email            Example xxxxxxxx@outlook.com	
#>

$numberToFind = "111-222-3333" #Must be in the format XXX-XXX-XXXX because that is what we use for cell phones for XXX-XXX-XXXX Ext:XXX for desk phones
$adUsers = Get-ADUser -Filter * -Properties *

foreach ($user in $adUsers) {
    if ($user.Mobile -eq $numberToFind) {
        Write-Host "Phone number $numberToFind belongs to $($user.Name) as their cell phone in location in ADUC Telephone Tab > Cell Phone"
    }
    if ($user.MobilePhone -eq $numberToFind) {
        #This is not a duplicate of Mobile technically so do not remove
        Write-Host "Phone number $numberToFind belongs to $($user.Name) as their cell phone in location in ADUC Telephone Tab > Cell Phone"
    }
    if ($user.OfficePhone -eq $numberToFind) {
        Write-Host "Phone number $numberToFind belongs to $($user.Name) in location in ADUC General Tab > Phone Number"
    }
    if ($user.HomePhone -eq $numberToFind) {
        Write-Host "Phone number $numberToFind belongs to $($user.Name) as their desk phone in location in ADUC Telephone Tab > Home Phone"
    }
}
