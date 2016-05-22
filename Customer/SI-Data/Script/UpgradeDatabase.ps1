$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')


clear-host

$StartedDateTime = Get-Date

#Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}

New-NAVEnvironment -ServerInstance $ModifiedServerInstance -BackupFile $ModifiedDatabaseBackupLocation -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
Import-NAVServerLicense -LicenseFile $NAVLicense -ServerInstance $ModifiedServerInstance 
Set-NAVServerInstance -ServerInstance $ModifiedServerInstance -Restart

[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split

#Clear-Host

UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject

$UpgradeAction = [UpgradeAction]::Merge
UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject -OpenConflictFilesInKdiff $True

#$UpgradeAction = [UpgradeAction]::Join
#UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
#                -UpgradeAction $UpgradeAction -CompareObject $CompareObject `
#                -CompareObject $CompareObject -RemoveOriginalFilesNotInTarget $True -RemoveModifyFilesNotInTarget $True

RemoveOriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -OriginalFolder $OriginalFolder -TargetFolder $TargetFolder
RemoveModifiedFilesNotInTarget -WorkingFolderPath $WorkingFolder -ModifiedFolder $ModifiedFolder -TargetFolder $TargetFolder
Join-NAVApplicationObjectFile -Destination $DestinationFile -Source $JoinFolder -Force

# Restore company database, to be upgraded.
Backup-SqlDatabase -ServerInstance $DBServer -Database NAV71CU29SIDataObjects -BackupAction Database -BackupFile E:\Backup\SI-Data\SQL02\NAV71CU29SIDataObjects.bak -CompressionOption Default
Restore-SQLBackupFile -DatabaseName NAV71CU29SIDataObjects -BackupFile E:\Backup\SI-Data\SQL02\NAV71CU29SIDataObjects.bak 
Restore-SQLBackupFile-SID -BackupFile $BackupfileCaompanyDB -DatabaseName $UpgradeName

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step1.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step2.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step3.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step4.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow


$BackupFileName = 'NAV2009R2_SIDATA' + "_Step3.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database 'NAV2009R2_SIDATA' -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = 'NAV2015CU8_SIData' + "_Step3.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database 'NAV2015CU8_SIData' -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step6.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default -LogTruncationType Truncate
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
#Restore-SQLBackupFile-SID -BackupFile $BackupFilePath -DatabaseName $UpgradeName
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_NAV2013.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default -LogTruncationType Truncate
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

#New-NAVServerInstance -ManagementServicesPort 7045 -ServerInstance $UpgradeName -ClientServicesCredentialType Windows -SOAPServicesPort 7047
New-NAVEnvironment -Databasename $UpgradeName -DatabaseServer $DBServer -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance $UpgradeName
# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $UpgradeName

#Step 8
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step8.bak"
#$BackupFilePath = $BackupPath + $BackupFileName 
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default -LogTruncationType Truncate
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

#Step 9
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step9.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default -LogTruncationType Truncate
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

#Step 10
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeName + "_Step10.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default -LogTruncationType Truncate
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow


Sync-NAVTenant -ServerInstance nav71cu29sidata
Sync-NAVTenant -ServerInstance nav71sidata
Sync-NAVTenant -ServerInstance nav71cu29sidataDen

Remove-NAVApplication -DatabaseName NAVSIData -DatabaseServer sql02

#Export all data from database
$StartedDateTime = Get-Date
Export-NAVData -DatabaseServer $DBServer -DatabaseName $UpgradeName -FileName (join-path $BackupPath  ($UpgradeName + '_AllCompanies.navdata')) -AllCompanies -IncludeApplicationData -IncludeGlobalData -IncludeApplication
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow
#Create new empty database on the server with the right Collation
#Give server instance user DBOwner access on the database.
#Import-NAVData -DatabaseServer SQL02 -DatabaseName NAVSIData -AllCompanies -FileName (join-path $BackupPath  ($UpgradeName + '.navdata')) -IncludeGlobalData -IncludeApplicationData -IncludeApplication
# starts at 13:40
Import-NAVData -DatabaseServer SQL02 -DatabaseName NAVSIDataDen -AllCompanies -FileName (join-path $BackupPath  ($UpgradeName + '_AllCompanies.navdata')) -IncludeGlobalData -IncludeApplicationData -IncludeApplication
#New-NAVEnvironment -Databasename NAVSIDataDen -DatabaseServer sql02 -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance NAV71CU29SIDataDen

Copy-NAVCompany -DestinationCompanyName "Test 1" -ServerInstance nav71sidata -SourceCompanyName "SI-Data A/S"
  
$StoppedDateTime = Get-Date
  
Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

