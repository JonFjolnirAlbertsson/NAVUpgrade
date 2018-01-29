# Client script to start remote session on application server
Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$Location = (Split-Path $psise.CurrentFile.FullPath)
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettingsClient.ps1')
. $scriptLocationPath
# Client Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role Client -DelegateComputer $NAVServer  -Force
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName $NAVServer -UseSSL -Credential $UserCredential –Authentication CredSSP
#Enter-PSSession -ComputerName $DBServer -UseSSL -Credential $UserCredential
#Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

# Server Site script
clear-host
$StartedDateTime = Get-Date
Set-Location 'C:\'
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\Incadea\FastFit\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettingsServer.ps1'
. $scriptLocationPath
Import-Certificate -Filepath $CertificateFile -CertStoreLocation "Cert:\LocalMachine\Root"
## Server Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role server -Force

# Import NAV, cloud.ready and incadea modules
# To be able to import the moduel sqlps
# files had to be copied from folder "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules" to the folder "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" 
Import-module (Join-Path "$GitPath\Cloud.Ready.Software.PowerShell\PSModules" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-module (Join-Path "$GitPath\IncadeaNorway" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -Force -WarningAction SilentlyContinue | out-null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1" -Force -WarningAction SilentlyContinue | Out-Null
Import-Module SQLPS -DisableNameChecking 
# Restore W1 databases
Restore-SQLBackupFile-INC -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER2DB -DatabaseServer $DBServer -DatabaseName $DEALER2DBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileMASTERDB -DatabaseServer $DBServer -DatabaseName $MASTERDBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileREPORTINGDB -DatabaseServer $DBServer -DatabaseName $REPORTINGDBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileSTAGINGDB -DatabaseServer $DBServer -DatabaseName $STAGINGDBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileTEMPLATEDB -DatabaseServer $DBServer -DatabaseName $TEMPLATEDBNameW1
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoDBW1  -DatabaseServer $DBServer -DatabaseName $DemoDBW1
# Restore NO databases
Restore-SQLBackupFile-INC -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBNameNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNO 
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoDBNO  -DatabaseServer $DBServer -DatabaseName $DemoDBNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBNameNODev
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNODev 
# Backup the development database that will be upgraded
$BackupFileName = $UpgradeFromDevDBName + "_BeforeUpgradeTo$UpradeFromVersion.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeFromDevDBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Creating NAV Server Instances
Write-host "Create Service Instance"
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstanceW1 -DatabaseServer $DBServer
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstance -DatabaseServer $DBServer
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstanceDev -DatabaseServer $DBServer
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName , $InstanceSecurePassword 
# Set instance to Multitenant
$CurrentServerInstanceW1 = Get-NAVServerInstance -ServerInstance $FastFitInstanceW1
$CurrentServerInstanceNO = Get-NAVServerInstance -ServerInstance $FastFitInstanceNO
$CurrentServerInstanceNODev = Get-NAVServerInstance -ServerInstance $FastFitInstanceNODev
Write-host "Prepare NST for MultiTenancy"
$CurrentServerInstanceW1 | Set-NAVServerInstance -stop
$CurrentServerInstanceW1 | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstanceW1 | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstanceW1 | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstanceW1 | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstanceW1 | Set-NAVServerInstance -start
# Set instance to Multitenant
$CurrentServerInstanceNO | Set-NAVServerInstance -stop
$CurrentServerInstanceNO | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstanceNO | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstanceNO | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstanceNO | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstanceNO | Set-NAVServerInstance -start
# Set instance to Multitenant
$CurrentServerInstanceNODev | Set-NAVServerInstance -stop
$CurrentServerInstanceNODev | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstanceNODev | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstanceNODev | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstanceNODev | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstanceNODev | Set-NAVServerInstance -start
Write-host "Mount app"
$CurrentServerInstanceNO | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameNO 
$CurrentServerInstanceW1 | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameW1
$CurrentServerInstanceNODev | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameNODev   
Write-host "Mount Tenants"
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $DEALER1DBNameW1 -Id $Dealer1TenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $DEALER1DBNameNO -Id $Dealer1TenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNODev -DatabaseName $DEALER1DBNameNODev -Id $Dealer1TenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
# Import License
$CurrentServerInstanceW1 | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstanceW1 | Set-NAVServerInstance -Restart
$CurrentServerInstanceNO | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstanceNO | Set-NAVServerInstance -Restart
$CurrentServerInstanceNODev | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstanceNODev | Set-NAVServerInstance -Restart
# Sync database
Sync-NAVTenant -ServerInstance $FastFitInstanceW1 -Tenant $Dealer1TenantW1 -Mode ForceSync
Sync-NAVTenant -ServerInstance $FastFitInstanceNO -Tenant $Dealer1TenantNO -Mode ForceSync
Sync-NAVTenant -ServerInstance $FastFitInstanceNODev -Tenant $Dealer1TenantNO -Mode ForceSync
# Add user to database
#Remove-NAVServerUser -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
#Remove-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
New-NAVUser-INC -NavServiceInstance $FastFitInstanceW1 -User $UserName -Tenant $Dealer1TenantW1
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $Dealer1TenantNO
New-NAVUser-INC -NavServiceInstance $CurrentServerInstanceNODev -User $UserName -Tenant $Dealer1TenantNO
#Get-NAVServerUser -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant
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

$fileNames = Get-ChildItem -Path $ConflictTarget -Recurse -Include *.txt
foreach($filename in $fileNames)
{
    $Source = join-path $SourcePath  $filename.Name
    $Destination = join-path $MergedPath  $filename.Name
    Copy-Item $Source -Destination $Destination
    Write-Host $Source + ' file copied to ' + $Destination
}
#Copy merged result items to the join folder
$fileNames = Get-ChildItem -Path $SourcePath -Recurse -Include *.txt
foreach($filename in $fileNames)
{
    $Source = join-path $SourcePath  $filename.Name
    $Destination = join-path $JoinPath  $filename.Name
    Copy-Item $Source -Destination $Destination
    Write-Host $Source + ' file copied to ' + $Destination
}
#$NOObjects = join-path $WorkingFolder 'NO_Objects.txt'
#Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $TargetDemoDBName -Username $DBUser -Password $InstancePassword -Path $NOObjects -Filter 'Id=10600..10699|15000000..15000999' -LogPath $LogPath

#Join-NAVApplicationObjectFile -Destination $JoinFile -Source $Destination
Merge-NAVCode -WorkingFolderPath $WorkingFolder -Join
#Create Web client instance
New-NAVWebServerInstance -WebServerInstance $FastFitInstanceNO  -Server $NAVServer -ServerInstance $FastFitInstanceNO 
New-NAVWebServerInstance -WebServerInstance $FastFitInstanceNODev  -Server $NAVServer -ServerInstance $FastFitInstanceNODev 
# Backup
$BackupFileName = $AppDBNameNO + "_Without_DEU.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $AppDBNameNO -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = $DEALER1DBNameNO + "_Without_DEU.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $DEALER1DBNameNO -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
