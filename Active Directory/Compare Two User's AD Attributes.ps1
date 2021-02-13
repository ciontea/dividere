$user1 = "David Ciontea" #The correct user
$user2 = "Geroge Bob" #The user you want to make sure has the same AD attributes as user 1 since user 1 is set up correctly

$global:adUsers = Get-ADUser -Filter * -Properties * | Sort-Object Name
$user1 = $adUsers | Where-Object Name -eq $user1
$user2 = $adUsers | Where-Object Name -eq $user2
$properties = ($user1 | Get-Member -MemberType Property, Properties)
$allDiferences = @()

foreach ($property in $properties) {
    Compare-Object $user1 -DifferenceObject $user2 -Property $property.Name | Format-Table -AutoSize
}
$allDiferences
