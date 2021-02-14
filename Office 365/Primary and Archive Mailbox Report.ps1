#Purpose: Get information on all user's primary and archive mailbox (if they have one) usage information. Report will only run on Tuesday's but this can be removed

$global:mailboxes              = Get-Mailbox -ResultSize Unlimited

if ((Get-Date -Format "dddd") -like "*Tuesday*") {
        foreach ($mailbox in $mailboxes) {
            #Report 1: Getting a report of all primary mailboxes and archive mailbox sizes
                #Finding mailbox and online archive mailbox size information
                    $LastProcessed = $Null
                    $mailboxstats = Get-MailboxStatistics $mailbox.userprincipalname
                    if ($mailbox.ArchiveStatus -eq "Active") {
                        $archivemailboxstats = Get-MailboxStatistics -archive $mailbox.userprincipalname
                        $archivesize = $archivemailboxstats.TotalItemSize
                        $archiveitemcount = $archivemailboxstats.ItemCount
                    } else {
                        $archivesize = $null
                        $archiveitemcount = $null
                    }

                #Creating a column in Excel report that contains just the mailboxes size in GB so it can be filtered
                    #Primary Mailbox
                        [string]$dirtySize = $mailboxstats.TotalItemSize.Value
                        if ($dirtySize -like "*KB*") {
                            [string]$primaryMailboxGB = $dirtySize.Substring(0, $dirtySize.LastIndexOf(' KB')) #Variable must be a string to use the .SubString method
                            $primaryMailboxGB = [decimal]$primaryMailboxGB / 1000000 #Converting to GB
                        } elseif ($dirtySize -like "*MB*") {
                            [string]$primaryMailboxGB = $dirtySize.Substring(0, $dirtySize.LastIndexOf(' MB')) #Variable must be a string to use the .SubString method
                            $primaryMailboxGB = [decimal]$primaryMailboxGB / 1000 #Converting to GB
                        } elseif ($dirtySize -like "*GB*") {
                            [string]$primaryMailboxGB = $dirtySize.Substring(0, $dirtySize.LastIndexOf(' GB')) #Variable must be a string to use the .SubString method
                        }
                    #Archive Mailbox
                        [string]$dirtySize = $archivesize.Value
                        if ($dirtySize -like "*KB*") {
                            [string]$archiveMailboxGB = $dirtySize.Substring(0, $dirtySize.LastIndexOf(' KB')) #Variable must be a string to use the .SubString method
                            $archiveMailboxGB = [decimal]$primaryMailboxGB / 1000000 #Converting to GB
                        } elseif ($dirtySize -like "*MB*") {
                            [string]$archiveMailboxGB = $dirtySize.Substring(0, $dirtySize.LastIndexOf(' MB')) #Variable must be a string to use the .SubString method
                            $archiveMailboxGB = [decimal]$primaryMailboxGB / 1000 #Converting to GB
                        } elseif ($dirtySize -like "*GB*") {
                            [string]$archiveMailboxGB = $dirtySize.Substring(0, $dirtySize.LastIndexOf(' GB')) #Variable must be a string to use the .SubString method
                        }

                #Making sure that the primary mailbox is not larger than 50GB or it could mean there is an issue with the archive mailbox or that it was never enabled, etc.
                    if ($primaryMailboxGB -gt 50) {
                        $primaryTooLarge = "Investigate Mailbox Size!"
                    } else {
                        $primaryTooLarge = $null
                    }

                #Making sure folders do not reach the limit of Outlook cached mode or there will be serious Outlook issues. https://docs.microsoft.com/en-us/outlook/troubleshoot/performance/performance-issues-if-too-many-items-or-folders
                    $foldersnearing100k = @()
                    $foldercounts = Get-MailboxFolderStatistics $mailbox.userprincipalname
                    foreach ($folder in $foldercounts) {
                        if ($folder.Name -ne "Purges") {
                            if ($folder.FolderPath -like "/Calendar*") {
                                #Finding users with calendar folders nearing 5k limit
                                if ($folder.ItemsinFolder -gt 4800) {
                                    $CalendarFoldersNearing5k += "Folder Name: """ + $folder.Name + """ Items in Folder: " + $folder.ItemsinFolder + ","
                                }
                            } else {
                                #Finding users with regular folders nearing 100k limit
                                if ($folder.ItemsinFolder -gt 98000) {
                                    $foldersnearing100k += "Folder Name: """ + $folder.Name + """ Items in Folder: " + $folder.ItemsinFolder + ","
                                }
                            }
                        }
                    }
                    $foldersnearing100k = [string]$foldersnearing100k #An array can't be stored in a single Excel cell so it must be converted back to string even if it starts an array on each loop
                    $CalendarFoldersNearing5k = [string]$CalendarFoldersNearing5k #An array can't be stored in a single Excel cell so it must be converted back to string even if it starts an array on each loop

                #Finding the last time archiving was performed on each mailbox if it has archiving enabled
                    $Log = Export-MailboxDiagnosticLogs -Identity $mailbox.userprincipalname -ExtendedProperties
                    $xml = [xml]($Log.MailboxLog)
                    $LastProcessed = ($xml.Properties.MailboxTable.Property | Where-Object {$_.Name -like "*ELCLastSuccessTimestamp*"}).Value
                    $ItemsDeleted  = $xml.Properties.MailboxTable.Property | Where-Object {$_.Name -like "*ElcLastRunDeletedFromRootItemCount*"}
                    if ($null -eq $LastProcessed) {$LastProcessed = "Not processed"}

                    $ruleHash = $null
                    $ruleHash = [ordered]@{
                        Mailbox                   = $mailbox.identity
                        MailboxUPN                = $mailbox.userprincipalname
                        RecipientTypeDetails      = $mailbox.RecipientTypeDetails
                        PrimarySize               = $mailboxstats.TotalItemSize
                        PrimarySizeInGB           = $primaryMailboxGB
                        PrimaryItemCount          = $mailboxstats.ItemCount
                        PrimaryOver50GB           = $primaryTooLarge
                        ArchiveSize               = $archivesize
                        ArchiveSizeInGB           = $archiveMailboxGB
                        ArchiveItemCount          = $archiveitemcount
                        FoldersNearing100k        = $foldersnearing100k
                        CalendarFoldersNearing5k  = $CalendarFoldersNearing5k
                        LastProcessedArchive      = $LastProcessed
                        ItemsDeleted              = $ItemsDeleted.Value
                    }
                    $ruleObject = New-Object PSObject -Property $ruleHash
                    $ruleObject | Export-Csv "$logpath\MailboxSizes-$date.csv" -NoTypeInformation -Append
    }
}
