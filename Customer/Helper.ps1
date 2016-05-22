$ServerInstance  = 'NAV90SIDataUpgrade'

Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
$null = Set-NAVServerInstance -Start -ServerInstance $ServerInstance


    if($LicenseFile){  
        Write-Host -ForegroundColor Green -Object 'Importing license..'
        $null = $ServerInstanceObject | Import-NAVServerLicense -LicenseFile $LicenseFile -Force -WarningAction SilentlyContinue
    }
$ServerInstance  = 'NAV71CU29SIData'  
$ServerInstance  = 'NAV71SIData'  
$ServerInstance  = 'DynamicsNAV90'  
$ServerInstance  = 'NAV90_OsloFinerObject' 
$ServerInstance  = 'DynamicsNAV71' 
$ServerInstance  = 'NAV71CU29SIData'          
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


Restore-SQLBackupFile-SID -BackupFile 'C:\NavUpgrade\Elas\CustomerDBs\NAV90CU5Elas_Step12\NAV90CU5Elas_Step12.bak' -DatabaseName 'NAV90Elas'
New-NAVEnvironment -Databasename 'NAV90Elas' -DatabaseServer localhost -EnablePortSharing -LicenseFile 'C:\NavUpgrade\License\NAV2016.flf' -ServerInstance 'NAV90Elas'
New-NAVEnvironment -Databasename 'NAV2016CU1_Busch' -DatabaseServer localhost -EnablePortSharing -LicenseFile 'C:\NavUpgrade\License\NAV2016.flf' -ServerInstance 'NAV90Busch'

$ADuser = "SQLNAVUPGRADE\jal"
$ADuser = "SQLNAVUPGRADE\vmadmin"
$NavServiceInstance = "NAV90Elas"
$NavServiceInstance = "NAV90Busch"
Sync-NAVTenant -ServerInstance $NavServiceInstance 
Get-NAVServerInstance $UpgradeName | New-NAVServerUser -WindowsAccount $ADuser 
Get-NAVServerInstance $UpgradeName | New-NAVServerUserPermissionSet –WindowsAccount $ADuser -PermissionSetId SUPER -Verbose
