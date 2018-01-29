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
# Had to copy the files in folder "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules" to the folder "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" 
# To be able to import the moduel sqlps
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
Restore-SQLBackupFile-INC -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBName
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBName 
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoDBNO  -DatabaseServer $DBServer -DatabaseName $DemoDBNO
# Backup the development database that will be upgraded
$BackupFileName = $UpgradeFromDevDBName + "_BeforeUpgradeTo$UpradeFromVersion.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeFromDevDBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

# Must run in remote session, if the server instance is run on another server.
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstanceW1 -DatabaseServer $DBServer
# Remove-SQLDatabase -DatabaseName $DEALER1DBName
Write-host "Create Service Instance"
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstance -DatabaseServer $DBServer
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName , $InstanceSecurePassword 
# Set instance to Multitenant
$CurrentServerInstanceW1 = Get-NAVServerInstance -ServerInstance $FastFitInstanceW1
$CurrentServerInstance = Get-NAVServerInstance -ServerInstance $FastFitInstance
Write-host "Prepare NST for MultiTenancy"
$CurrentServerInstanceW1 | Set-NAVServerInstance -stop
$CurrentServerInstanceW1 | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstanceW1 | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstanceW1 | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstanceW1 | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstanceW1 | Set-NAVServerInstance -start
# Set instance to Multitenant
Write-host "Prepare NST for MultiTenancy"
$CurrentServerInstance | Set-NAVServerInstance -stop
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstance | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstance | Set-NAVServerInstance -start
Write-host "Mount app"
$CurrentServerInstance | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameNO 
$CurrentServerInstanceW1 | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameW1  
Write-host "Mount Tenants"
#Mount-NAVTenant -ServerInstance DynamicsNAV71 -Id $MainTenant -DatabaseName $Databasename -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstance -DatabaseName $DEALER1DBNameNO -Id $Dealer1TenantNO  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $DEALER1DBNameW1 -Id $Dealer1TenantW1  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
# Import License
$CurrentServerInstanceW1 | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstanceW1 | Set-NAVServerInstance -Restart
$CurrentServerInstance | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstance | Set-NAVServerInstance -Restart
# Sync database
Sync-NAVTenant -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant
Sync-NAVTenant -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant -Mode ForceSync
Sync-NAVTenant -ServerInstance $FastFitInstanceW1 -Tenant $Dealer1TenantW1 -Mode ForceSync
# Add user to database
#Remove-NAVServerUser -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
#Remove-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
CreateNAVUser -NavServiceInstance $FastFitInstanceW1 -User $UserName -Tenant $Dealer1TenantW1
CreateNAVUser -NavServiceInstance $FastFitInstance -User $UserName -Tenant $Dealer1TenantNO
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
New-NAVWebServerInstance -WebServerInstance $FastFitInstance  -Server $NAVServer -ServerInstance $FastFitInstance 
New-NAVWebServerInstance -WebServerInstance $FastFitInstanceDev  -Server $NAVServer -ServerInstance $FastFitInstanceDev 
# Backup
$BackupFileName = $AppDBName + "_Without_DEU.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $AppDBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$BackupFileName = $DEALER1DBName + "_Without_DEU.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $DEALER1DBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
