#To start remote session on application server
$Location = 'C:\GitHub\NAVUpgrade\Customer\Incadea\FastFit\Script\'
. (join-path $Location 'Set-UpgradeSettings.ps1')
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName NO01DEV03 -UseSSL -Credential $UserCredential

$Location = 'C:\GitHub\NAVUpgrade\Customer\Incadea\FastFit\Script\'
. (join-path $Location 'Set-UpgradeSettings.ps1')
Import-Certificate -Filepath "C:\GitHub\NAVUpgrade\Customer\Incadea\FastFit\cert" -CertStoreLocation "Cert:\LocalMachine\Root"

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
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName, $InstanceSecurePassword 
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 

# Restore company database, to be upgraded. Can be run locally.
Restore-SQLBackupFile-SID -BackupFile $BackupfileNAVDemoDB -DatabaseServer $DBServer -DatabaseName $DemoDBName
Restore-SQLBackupFile-SID -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBName
Restore-SQLBackupFile-SID -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBName 
Restore-SQLBackupFile-SID -BackupFile $BackupfileNAVTargetDemoDB -DatabaseServer $DBServer -DatabaseName $TargetDemoDBName
Restore-SQLBackupFile-SID -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBNameW1
Restore-SQLBackupFile-SID -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameW1
#Must run in remote session, if the server instance is run on another server.
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstanceW1 -DatabaseServer $DBServer
#Remove-SQLDatabase -DatabaseName $DEALER1DBName
Write-host "Create Service Instance"
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstance -DatabaseServer $DBServer
# Set instance to Multitenant
$CurrentServerInstance = Get-NAVServerInstance -ServerInstance $FastFitInstance
$CurrentServerInstance = Get-NAVServerInstance -ServerInstance $FastFitInstanceW1
Write-host "Prepare NST for MultiTenancy"
$CurrentServerInstance | Set-NAVServerInstance -stop
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstance | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstance | Set-NAVServerInstance -start
$CurrentServerInstance | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstance | Set-NAVServerInstance -Restart $InstanceUserName 

Write-host "Mount app"
$CurrentServerInstance | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBName 
$CurrentServerInstance | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameW1  
Write-host "Mount Tenants"
#Mount-NAVTenant -ServerInstance DynamicsNAV71 -Id $MainTenant -DatabaseName $Databasename -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstance -DatabaseName $DEALER1DBName -Id $Dealer1Tenant  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $DEALER1DBNameW1 -Id $Dealer1TenantW1  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase

Sync-NAVTenant -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant
Sync-NAVTenant -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant -Mode ForceSync
Sync-NAVTenant -ServerInstance $FastFitInstanceW1 -Tenant $Dealer1TenantW1 -Mode ForceSync
#Remove-NAVServerUser -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
#Remove-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
New-NAVServerUser -ServerInstance $FastFitInstance -WindowsAccount $UserName -Tenant $Dealer1Tenant -LicenseType Full -State Enabled
New-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $FastFitInstance -WindowsAccount $UserName -Tenant $Dealer1Tenant 
Get-NAVServerUser -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant
#Export all objects from Demo DB to text file.
#Export-NAVApplicationObject2 -Path $TargetObjects -ServerInstance $NavServiceInstance -LogPath $LogPath

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $FastFitObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
<#
$CompareObject = '*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

# Join Merged objects to one text file.
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -CompareObject $CompareObject -Join
#>

# Backup
$BackupFileName = $AppDBName + "_Without_DEU.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $AppDBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = $DEALER1DBName + "_Without_DEU.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $DEALER1DBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
