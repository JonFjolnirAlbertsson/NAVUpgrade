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
$BackupFileName = $UpgradeName + "_Step1.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

$BackupFileName = $UpgradeName + "_Step2.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = $UpgradeName + "_Step3.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = 'NAV2009R2_SIDATA' + "_Step3.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database 'NAV2009R2_SIDATA' -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = 'NAV2015CU8_SIData' + "_Step3.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database 'NAV2015CU8_SIData' -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#$BackupFileName = $UpgradeName + "_Step3.bak"
#$BackupFilePath = join-path $BackupPath  $BackupFileName 
#Restore-SQLBackupFile-SID -BackupFile $BackupFilePath -DatabaseName $UpgradeName
$BackupFileName = $UpgradeName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = $UpgradeName + "_Step6.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = $UpgradeName + "_NAV2013.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

New-NAVServerInstance -ManagementServicesPort 7045 -ServerInstance $UpgradeName -ClientServicesCredentialType Windows -SOAPServicesPort 7047
# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $UpgradeName

#Step 9
$BackupFileName = $UpgradeName + "_Step9.bak"
$BackupFilePath = $BackupPath + $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 10
$BackupFileName = $UpgradeName + "_Step10.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
#Step 11
$BackupFileName = $UpgradeName + "_Step11.bak"
$BackupFilePath = join-path $BackupPath  $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default


Sync-NAVTenant -ServerInstance nav71cu29sidata
Sync-NAVTenant -ServerInstance nav71sidata
Sync-NAVTenant -ServerInstance nav71cu29sidataDen

Remove-NAVApplication -DatabaseName NAVSIData -DatabaseServer sql02

#Export all data from database
Export-NAVData -DatabaseServer JALW8 -DatabaseName $UpgradeName -FileName (join-path $BackupPath  ($UpgradeName + '_AllCompanies.navdata')) -AllCompanies -IncludeApplicationData -IncludeGlobalData -IncludeApplication
#Create new empty database on the server with the right Collation
#Give server instance user DBOwner access on the database.
Import-NAVData -DatabaseServer SQL02 -DatabaseName NAVSIData -AllCompanies -FileName (join-path $BackupPath  ($UpgradeName + '.navdata')) -IncludeGlobalData -IncludeApplicationData -IncludeApplication
# starts at 13:40
#Get-NAVDataFile -FileName (join-path $BackupPath  ($UpgradeName + '_AllCompanies.navdata')) 
#Remove-NAVApplication -DatabaseServer $DBServer -DatabaseName NAV71SIDataDev
$StartedDateTime = Get-Date
Import-NAVData -DatabaseServer $DBServer -DatabaseName NAV71SIDataDev  -CompanyName 'SI-DATA København A/S' -FileName (join-path $BackupPath  ($UpgradeName + '_AllCompanies.navdata')) -IncludeGlobalData -IncludeApplicationData -IncludeApplication
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
Import-NAVData -DatabaseServer $DBServer -DatabaseName NAV71SIDataDev  -CompanyName 'SI-Data A/S' -FileName (join-path $BackupPath  ($UpgradeName + '_AllCompanies.navdata'))  -IncludeApplicationData 
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

New-NAVEnvironment -Databasename NAV71SIDataDev -DatabaseServer sql02 -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance NAV71SIDataDev
Sync-NAVTenant -ServerInstance NAV71SIDataDev

Copy-NAVCompany -DestinationCompanyName "Test 1" -ServerInstance nav71sidata -SourceCompanyName "SI-Data A/S"
  
$StoppedDateTime = Get-Date
  
Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

