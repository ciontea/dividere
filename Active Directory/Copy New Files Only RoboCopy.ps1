#Purpose: Needed to combine all 5 folders into one main folder so I needed to see which folder had the latest version of file to move into the master folder

$allLocations = @(
    "C:\Users\User1\Folder1",
    "C:\Users\User1\Folder2",
    "C:\Users\User1\Folder3",
    "C:\Users\User1\Folder4",
    "C:\Users\User1\Folder5"
)

foreach ($path in $allLocations) {
    #Copying the files to the new location only if a newer version doesn't already exist in the folder (not overall)
        robocopy $path "C:\Users\User1\Final Folder" /s /xo #Will exclude older files from being copied over and excludes any empty subdirectories
}
