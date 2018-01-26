#To start remote session on application server
Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$Location = (Split-Path $psise.CurrentFile.FullPath)
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettingsClient.ps1')
. $scriptLocationPath
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName NO01DEV03 -UseSSL -Credential $UserCredential
Import-Certificate -Filepath $CertificateFile -CertStoreLocation "Cert:\LocalMachine\Root"

clear-host
$StartedDateTime = Get-Date

Set-Location 'C:\'
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\Incadea\FastFit\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettingsServer.ps1'
. $scriptLocationPath
<#
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName, $InstanceSecurePassword 
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
#>
# Restore company database, to be upgraded. Can be run locally.
#Restore-SQLBackupFile-SID -BackupFile $BackupfileNAVDemoDB -DatabaseServer $DBServer -DatabaseName $DemoDBName
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

Write-host "Mount app"
$CurrentServerInstance | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBName 
$CurrentServerInstance | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameW1  
Write-host "Mount Tenants"
#Mount-NAVTenant -ServerInstance DynamicsNAV71 -Id $MainTenant -DatabaseName $Databasename -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstance -DatabaseName $DEALER1DBName -Id $Dealer1Tenant  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $DEALER1DBNameW1 -Id $Dealer1TenantW1  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
#Import License
$CurrentServerInstance | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstance | Set-NAVServerInstance -Restart
#Sync database
Sync-NAVTenant -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant
Sync-NAVTenant -ServerInstance $FastFitInstance -Tenant $Dealer1Tenant -Mode ForceSync
Sync-NAVTenant -ServerInstance $FastFitInstanceW1 -Tenant $Dealer1TenantW1 -Mode ForceSync
#Remove-NAVServerUser -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
#Remove-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
New-NAVServerUser -ServerInstance $FastFitInstance -WindowsAccount $UserName -Tenant $Dealer1Tenant -LicenseType Full -State Enabled
New-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $FastFitInstance -WindowsAccount $UserName -Tenant $Dealer1Tenant 
New-NAVServerUser -ServerInstance $FastFitInstanceW1 -WindowsAccount $UserName -Tenant $Dealer1TenantW1 -LicenseType Full -State Enabled
New-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $FastFitInstanceW1 -WindowsAccount $UserName -Tenant $Dealer1TenantW1 
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
