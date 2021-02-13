################################################################### Log In Count ###################################################################
$logincountfile = "C:\temp\Login Count.txt"
$loginexist = Test-Path $logincountfile

if ($loginexist) {
    [int]$logincount = Get-Content $logincountfile
    $newlogincount = $logincount + 1
    Remove-Item -Path $logincountfile -Force
    New-Item -ItemType File -Path $logincountfile -Value $newlogincount
} else {
    New-Item -ItemType File -Path $logincountfile -Value 1 -Force
}
