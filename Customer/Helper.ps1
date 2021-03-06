﻿
$RootLicPath = 'C:\Users\jal\OneDrive for Business\Files\Incadea Norway AS\License'
$LicenseFile =  join-path $RootLicPath 'NAV2017.flf' 
$LicenseFile = join-path $RootLicPath 'SI-Data License 4804449.flf' 

Get-NAVServerInstance -ServerInstance DynamicsNAV100 | Copy-NAVEnvironment -ToServerInstance NAV100_TP

$ADuser = 'incadea\AlbertssonF'
Get-NAVServerInstance | where-Object  {$_.Version -like “7.1*” -And $_.State –eq ‘Running’} -ErrorAction Continue | New-NAVServerUser -WindowsAccount $ADuser | New-NAVServerUserPermissionSet –WindowsAccount $ADuser -PermissionSetId SUPER -Verbose

$ServerInstance  = 'NAV90SIDataUpgrade'
$ServerInstance  = 'DynamicsNAV71'  
Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
$null = Set-NAVServerInstance -Start -ServerInstance $ServerInstance


    if($LicenseFile){  
        Write-Host -ForegroundColor Green -Object 'Importing license..'
        $null = $ServerInstance | Import-NAVServerLicense -LicenseFile $LicenseFile -Force -WarningAction SilentlyContinue
    }
$ServerInstance  = 'NAV71CU29SIData'  
$ServerInstance  = 'NAV71SIData'  
$ServerInstance  = 'DynamicsNAV90'  
$ServerInstance  = 'NAV100Elas'          
$ServerInstance  = 'DynamicsNav'
$null = sc.exe config (get-service NetTcpPortSharing).Name Start= Auto
$null = Start-service NetTcpPortSharing
$null = sc.exe config (get-service  "*$ServerInstance*").Name depend= HTTP/NetTcpPortSharing
    
Set-NAVServerInstance -ServerInstance $ServerInstance -Restart

Sync-NAVTenant -ServerInstance $ServerInstance -Force
Sync-NAVTenant -ServerInstance $ServerInstance -Force -Mode Force
Sync-NAVTenant -ServerInstance $ServerInstance -Mode CheckOnly

Join-NAVApplicationObjectFile -Source "C:\NAVUpgrade\Customer\SI-Data\NAV 2016\Incadea\Merged\ToBeJoined" -Destination "C:\NAVUpgrade\Customer\SI-Data\NAV 2016\Incadea\all-merged-objects.txt"

New-NAVServerInstance -ManagementServicesPort 7045 -ServerInstance $ServerInstance -ClientServicesCredentialType Windows -ClientServicesPort 7046 -DatabaseName $UpgradeName -DatabaseServer $DBServer -ODataServicesPort 7048 -SOAPServicesPort 7047
Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance

$TestDataBaseName = 'NAV80CU17ElasPerfTest'
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step7.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $TestDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow

$StartedDateTime = Get-Date
Restore-SQLBackupFile-SID -BackupFile $BackupFilePath -DatabaseName $TestDataBaseName
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow
 
New-NAVEnvironment -Databasename $TestDataBaseName -DatabaseServer $DBServer -EnablePortSharing -LicenseFile $NAVLicense -ServerInstance $TestDataBaseName

Sync-NAVTenant -ServerInstance $TestDataBaseName -Mode CheckOnly
Sync-NAVTenant -ServerInstance $TestDataBaseName -Force

# Start Data upgrade NAV 2016
$StartedDateTime = Get-Date
Start-NAVDataUpgrade -ServerInstance $TestDataBaseName -FunctionExecutionMode Serial
Resume-NAVDataUpgrade -ServerInstance $TestDataBaseName
Stop-NAVDataUpgrade -ServerInstance $TestDataBaseName
# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $TestDataBaseName -Progress
Get-NAVDataUpgrade -ServerInstance $TestDataBaseName -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $TestDataBaseName -ErrorOnly | ogv

$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow


Restore-SQLBackupFile-SID -BackupFile 'C:\NAVUpgrade\Customer\Øveraasen\CustomerDBs\Incadea_28022017\Incadea_28022017.bak' -DatabaseName 'NAV2009R2_Øveraasen'
New-NAVEnvironment -Databasename 'NAV90Elas' -DatabaseServer localhost -EnablePortSharing -LicenseFile 'C:\NavUpgrade\License\NAV2016.flf' -ServerInstance 'NAV90Elas'
New-NAVEnvironment -Databasename 'NAV2016CU1_Busch' -DatabaseServer localhost -EnablePortSharing -LicenseFile 'C:\NavUpgrade\License\NAV2016.flf' -ServerInstance 'NAV90Busch'

$ADuser = "SQLNAVUPGRADE\jal"
$NavServiceInstance = "NAV90Elas"
$NavServiceInstance = "NAV90Busch"
Sync-NAVTenant -ServerInstance $NavServiceInstance 
Get-NAVServerInstance $NavServiceInstance | New-NAVServerUser -WindowsAccount $ADuser 
Get-NAVServerInstance $NavServiceInstance | New-NAVServerUserPermissionSet –WindowsAccount $ADuser -PermissionSetId SUPER -Verbose

$NavServiceInstance = "NAV71SIData"
$NavServiceInstance = "NAV100Elas"
$LicenseFile =  join-path $RootLicPath 'NAV2016.flf' 
$LicenseFile = join-path $RootLicPath 'SI-Data License 4804449.flf' 
Import-NAVServerLicense -LicenseFile $LicenseFile  -ServerInstance $NavServiceInstance
Set-NAVServerInstance -ServerInstance $NavServiceInstance -Restart
Sync-NAVTenant -ServerInstance $NavServiceInstance
