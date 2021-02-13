#If you have a csv you want to search for numbers that do not exist in AD. The .csv has two columns, first is name ("David Ciontea") and second column is number to be searched ("647-327-1593")
$csv = Import-Csv "C:\Users\dciontea\Downloads\PhoneNumbers.csv" #Must have column cellnumber with just the phone numbers in this column in format XXX-XXX-XXXX
$adUsers = Get-ADUser -Filter * -Properties *

$csv = $csv | Sort-Object Name
foreach ($line in $csv) {
    foreach ($user in $adUsers) {
        if ($user.Mobile -eq $line.cellnumber) {
            $numberOwner = $user
            $numberExist = $true
        }
        if ($user.MobilePhone -eq $line.cellnumber) {
            #This is not a duplicate of Mobile technically so do not remove
            $numberOwner = $user
            $numberExist = $true
        }
        if ($user.OfficePhone -eq $line.cellnumber) {
            $numberOwner = $user
            $numberExist = $true
        }
        if ($user.HomePhone -eq $line.cellnumber) {
            $numberOwner = $user
            $numberExist = $true
        }
    }
    if ($numberExist) {
        Write-Host "$($line.cellnumber) belongs to $($numberOwner.Name) in AD and in CSV, name is $($line.name)"
    } else {
        "","$($line.cellnumber) belongs to no one in AD. In CSV, the name of the number is $($line.name)","" | Write-Host -ForegroundColor Yellow
    }
    $numberOwner = $null
    $numberExist = $null
}
