#ConvertTo-NAVMultiTenantEnvironment -ServerInstance $TargetServerInstance
$ServerInstanceObject = Get-NAVServerInstance2 -ServerInstance $TargetServerInstance
$TenantObject = $ServerInstanceObject | Get-NAVTenant -Tenant default
$BackupFileName = 'Backup.Bak'
    
$BackupFile = Backup-SQLDatabaseToFile -DatabaseServer $TenantObject.DatabaseServer -DatabaseName $TenantObject.DatabaseName -BackupFile $BackupFileName 
    
Restore-SQLBackupFile -BackupFile $BackupFile -DatabaseServer $TenantObject.DatabaseServer -DatabaseName 'Shared_TEST_B' 
remove-item $BackupFile -Force
    
Mount-NAVTenant -ServerInstance $TargetServerInstance -DatabaseServer $TenantObject.DatabaseServer -DatabaseName 'Shared_TEST_B' -Id CompanyB -OverwriteTenantIdInDatabase 
Sync-NAVTenant -ServerInstance $TargetServerInstance -Tenant CompanyB -Mode Sync -Force

Get-NAVAppInfo -ServerInstance $TargetServerInstance -Tenant CompanyA
Get-NAVAppInfo -ServerInstance $TargetServerInstance -Tenant CompanyB
Get-NAVAppInfo -ServerInstance $TargetServerInstance -Tenant default
Get-NAVAppInfo -ServerInstance $TargetServerInstance 
Uninstall-NAVApp -ServerInstance $TargetServerInstance -Name "Demo" -Tenant default –Version 1.0.0.2 
Sync-NAVTenant -ServerInstance $TargetServerInstance -Tenant default -Mode Sync -Force
Unpublish-NAVApp -Path C:\GitHub\NAVUpgrade\Extensions\Packages\Demo_v1.0.0.2.navx -ServerInstance $TargetServerInstance
Get-NAVAppInfo -ServerInstance $TargetServerInstance -Name 'Demo' -Version 1.0.0.1 | Unpublish-NAVApp
Get-NAVTenant -ServerInstance $TargetServerInstance | Uninstall-NAVApp -Name "Demo" -Tenant default –Version 1.0.0.2 
Get-NAVTenant -ServerInstance $TargetServerInstance | Unpublish-NAVApp -Name "Demo" -Publisher 'Incadea Norge AS' -Version 1.0.0.2  
#Unpublish-NAVApp -Name "Demo" -ServerInstance $TargetServerInstance -Tenant default -Publisher 'Incadea Norge AS' -Version 1.0.0.2 