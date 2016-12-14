$Location = "C:\GitHub\NAVUpgrade\Customer\NOBI\Script"
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
#New-NAVEnvironment -ServerInstance $UpgradeObjectsName  -BackupFile $BackupfileTargetDB -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
#Restore-SQLBackupFile-SID -BackupFile $BackupfileOriginalDB -DatabaseName 'Demo Database NAV (9-9)'

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

#Step 1
$BackupFileName = $UpgradeDataBaseName + "_Step13.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

#NAV 2017
#Convert Database to NAV 2017
Invoke-NAVDatabaseConversion -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -LogPath $ConversionLog

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step14.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

#Create NAV Server Instance
New-NAVEnvironment -Databasename $UpgradeDataBaseName -DatabaseServer $DBServer -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance $UpgradeDataBaseName

$StartedDateTime = Get-Date
#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 
# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No
# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $UpgradeDataBaseName -Mode Sync

# Import Migrated NAV 2017 objects with company migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2017APPObjects2Import -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2017 upgrade objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2017UpgradeObjects2Import -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose 
# Compile all objects
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $UpgradeDataBaseName -Mode Sync
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step15.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

# Start Data upgrade NAV 2016
$StartedDateTime = Get-Date
Start-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -FunctionExecutionMode Serial
Resume-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName
Stop-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName

# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -Progress
Get-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -ErrorOnly | ogv

#Restore-SQLBackupFile-SID -BackupFile $BackupFilePath -DatabaseName $UpgradeDataBaseName
Restore-SQLBackupFile-SID -BackupFile $BackupFilePath -DatabaseName ($UpgradeDataBaseName + '_Test')

$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step16.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow


