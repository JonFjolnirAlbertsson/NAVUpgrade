$Location = "C:\Git\NAVUpgrade\Customer\Øveraasen\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')

clear-host

$StartedDateTime = Get-Date

#Export all objects from Demo DB to text file.
Export-NAVApplicationObject2 -Path $TargetObjects -ServerInstance $NavServiceInstance -LogPath $LogPath

# Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}

# Restore company database, to be upgraded.
# New-NAVEnvironment -ServerInstance $UpgradeObjectsName  -BackupFile $BackupfileCaompanyDB -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
#Restore-SQLBackupFile-SID -BackupFile $BackupfileCaompanyDB -DatabaseName $UpgradeName

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

#NAV2017
$CompareObject = 'COD*.TXT'
#$CompareObject = '*.TXT' #All objects
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Merge
#Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -RemoveOriginalFilesNotInTarget -Join 


# Join Merged objects to one text file.
#Join-NAVApplicationObjectFile -Destination "$WorkingFolder\StandardMerge.txt" -Source "$WorkingFolder\Merged\*.TXT"



