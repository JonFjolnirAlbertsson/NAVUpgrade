$Location = "C:\GitHub\NAVUpgrade\Customer\Busch\Script\CU5"
. (join-path $Location 'Set-UpgradeSettings.ps1')

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
Restore-SQLBackupFile-SID -BackupFile $BackupfileCaompanyDB -DatabaseName $UpgradeName

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

# Split object files and create folders.
$CompareObject = '*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
# Merge Customer database table objects and NAV 20009 table objects.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects  -CompareObject $CompareObject -Merge
# Use Merge-Helper to merge NAV conflict objects

# Join Merged objects to one text file.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

#Step 1
$BackupFileName = $UpgradeDataBaseName + "_Step1.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 2
$BackupFileName = $UpgradeDataBaseName + "_Step2.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 3
$BackupFileName = $UpgradeDataBaseName + "_Step3.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 4
$BackupFileName = $UpgradeDataBaseName + "_Step4.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 5
$BackupFileName = $UpgradeDataBaseName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 6
$BackupFileName = $UpgradeDataBaseName + "_Step6.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

New-NAVEnvironment -Databasename $UpgradeDataBaseName -DatabaseServer $DBServer -EnablePortSharing -ServerInstance $NAV2015ServerInstance
#Convert Database to NAV 2015
Invoke-NAVDatabaseConversion -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -LogPath $ConversionLog
#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 

# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No
# Import Migrated NAV 2015 objects with customer migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2015APPObjects2Import -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2015 upgrade objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2015UpgradeObjects -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Compile all objects
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -NavServerName $NavServer -Filter $Filter -NavServerInstance $NAV2015ServerInstance -Recompile -SynchronizeSchemaChanges Force
#Compile these object with force, we expect loss of this data.
$Filter = 'ID=10604'
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -NavServerName $NavServer -Filter $Filter -NavServerInstance $NAV2015ServerInstance -Recompile -SynchronizeSchemaChanges Force

Sync-NAVTenant -ServerInstance $NAV2015ServerInstance -Mode Sync
Sync-NAVTenant -ServerInstance $NAV2015ServerInstance -Mode CheckOnly
Get-History
#Step 7
$BackupFileName = $UpgradeDataBaseName + "_Step7.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

#Restore if the upgrade fails
#Restore from sql to use the right file paths
#Step 7
$BackupFileName = $UpgradeDataBaseName + "_Step7_1.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Start Data upgrade NAV 2015
Start-NAVDataUpgrade -ServerInstance $NAV2015ServerInstance -FunctionExecutionMode Serial
# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $NAV2015ServerInstance -Progress
Get-NAVDataUpgrade -ServerInstance $NAV2015ServerInstance -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $NAV2015ServerInstance -ErrorOnly | ogv
#Step 8
$BackupFileName = $UpgradeDataBaseName + "_Step8.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

#Convert Database to NAV 2016
Invoke-NAVDatabaseConversion -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -LogPath $ConversionLog
#Step 9
$BackupFileName = $UpgradeDataBaseName + "_Step9.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 

# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No
# Import Migrated NAV 2016 objects with customer migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2016APPObjects2Import -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2016 upgrade objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2016UpgradeObjects -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Compile all objects
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -NavServerName $NavServer -Filter $Filter -NavServerInstance $TargetServerInstance -Recompile -SynchronizeSchemaChanges Force

Sync-NAVTenant -ServerInstance $TargetServerInstance -Mode Sync
Sync-NAVTenant -ServerInstance $TargetServerInstance -Mode CheckOnly
Get-History
#Step 10
$BackupFileName = $UpgradeDataBaseName + "_Step10.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

# Start Data upgrade NAV 2015
Start-NAVDataUpgrade -ServerInstance $TargetServerInstance -FunctionExecutionMode Serial
# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $TargetServerInstance -Progress
Get-NAVDataUpgrade -ServerInstance $TargetServerInstance -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $TargetServerInstance -ErrorOnly | ogv
#Step 11
$BackupFileName = $UpgradeDataBaseName + "_Step11.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 12
$BackupFileName = $UpgradeDataBaseName + "_Step12.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

$StoppedDateTime = Get-Date
  
Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

