$Location = "C:\GitHub\NAVUpgrade\Customer\Elas\Script"
. (join-path $Location 'NAV2017-Settings.ps1')

clear-host

$StartedDateTime = Get-Date

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

# Split object files and create folders for NAV 2017.
$CompareObject = '*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split

# Merge Customer database table objects and table objects.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join


