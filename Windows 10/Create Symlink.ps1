#Purpose: This allows you to have a folder "appear" in 5 spots but only use space on the disk once
$linkLocation = "$env:APPDATA\ThermoKing EPC"
$sourceLocation = "C:\_SOFTWARE\ThermoKing EPC\ThermoKing EPC"

#Creating Symlink to files
New-Item -ItemType Directory -Path $linkLocation
New-Item -ItemType Directory -Path $sourceLocation
New-Item -ItemType Junction -Path $linkLocation -Value $sourceLocation #"-Path" is where the files are and "-Value" is where you want the symlink to be created
