$Location = "C:\GitHub\NAVUpgrade\Customer\Elas\Script"
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

# Reset Workingfolder
if (test-path $WorkingFolderNAV2009){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolderNAV2009 ?"){
        Remove-Item -Path $WorkingFolderNAV2009 -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}
# Split object files and create folders for NAV 2009.
$CompareObject = 'TAB*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetNAV2009Objects -CompareObject $CompareObject -Split
# Merge Customer database table objects and NAV 2009 table objects.
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetNAV2009Objects  -CompareObject $CompareObject -Merge
# Use Merge-Helper to merge NAv 2009 table objects

# Join Merged objects to one text file.
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -CompareObject $CompareObject -Join

# Reset Workingfolder 2015
if (test-path $WorkingFolderNAV2015){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolderNAV2015 ?"){
        Remove-Item -Path $WorkingFolderNAV2015 -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}
# Split object files and create folders for NAV 2015.
$CompareObject = 'TAB*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2015 -OriginalFileName $TargetNAV2009Objects -ModifiedFileName $ModifiedNAV2015Objects -TargetFileName $TargetNAV2015Objects -CompareObject $CompareObject -Split
# Copy NAV 2009 tables to Modifed
# Merge Customer database table objects and table objects.
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2015 -CompareObject $CompareObject -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2015 -CompareObject $CompareObject -Join

#NAV2016
$CompareObject = '*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

#Step 1
$BackupFileName = $UpgradeDataBaseName + "_Step1.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 2
$BackupFileName = $UpgradeDataBaseName + "_Step2.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

$BackupFileName = $UpgradeDataBaseName + "_Step3.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

$BackupFileName = $UpgradeDataBaseName + "_Step4.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime)

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step6.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

#NAV2015

#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 
# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No
#Create NAV Server Instance
New-NAVEnvironment -Databasename $UpgradeDataBaseName -DatabaseServer $DBServer -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance $NAV2015DBName
# Import Migrated NAV 2015 objects with company migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2015APPObjects2Import -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2015 upgrade objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2015UpgradeObjects2Import -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose 
# Compile all objects
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No
#Compile these object with force, we expect loss of this data.
$Filter = 'ID=10604'
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -NavServerName $DBServer -Filter $Filter -NavServerInstance $NAV2015DBName -NavServerManagementPort 7045 -Recompile -SynchronizeSchemaChanges Force

# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $NAV2015DBName -Mode Sync

# Force compile of these tables
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -NavServerName $DBServer -Filter $Filter -NavServerInstance $NAV2015DBName -NavServerManagementPort 7045 -Recompile -SynchronizeSchemaChanges Force

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step7.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

# Start Data upgrade NAV 2015
Start-NAVDataUpgrade -ServerInstance $NAV2015DBName -FunctionExecutionMode Serial

# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $NAV2015DBName -Progress
Get-NAVDataUpgrade -ServerInstance $NAV2015DBName -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $NAV2015DBName -ErrorOnly | ogv

#Resume-NAVDataUpgrade -ServerInstance $NAV2015DBName

#RestoreDBFromFile -backupFile 'F:\NAVUpgrade\Customer\Elas\CustomerDBs\NAV90CU5Elas_Step1.bak' -dbNewname 'NAV60ElasToBeUpgraded'
#Restore-SQLBackupFile-SID -BackupFile $BackupFilePath -DatabaseName $UpgradeDataBaseName

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step8.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

Set-NAVServerInstance -ServerInstance $NAV2015DBName -Stop

#NAV 2016
#Convert Database to NAV 2016
Invoke-NAVDatabaseConversion -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -LogPath $ConversionLog

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step9.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

#Create NAV Server Instance
New-NAVEnvironment -Databasename $UpgradeDataBaseName -DatabaseServer $DBServer -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance $UpgradeDataBaseName

$StartedDateTime = Get-Date
#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 

# Import Migrated NAV 2016 objects with company migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2016APPObjects2Import -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2016 upgrade objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAV2016UpgradeObjects2Import -DatabaseName $UpgradeDataBaseName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose 
# Compile all objects
Compile-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $UpgradeDataBaseName -Mode Sync
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step10.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

# Start Data upgrade NAV 2016
$StartedDateTime = Get-Date
Start-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -FunctionExecutionMode Serial

# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -Progress
Get-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $UpgradeDataBaseName -ErrorOnly | ogv

$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step11.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step12.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow




Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

