# Client script to start remote session on application server
Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$Location = (Split-Path $psise.CurrentFile.FullPath)
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettings.ps1')
. $scriptLocationPath
# Client Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role Client -DelegateComputer $NAVServerRSName  -Force
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName $NAVServerRSName -UseSSL -Credential $UserCredential –Authentication CredSSP
#Enter-PSSession -ComputerName $DBServer -UseSSL -Credential $UserCredential
#Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

# Server Site script
clear-host
$StartedDateTime = Get-Date
Set-Location 'C:\'
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\Incadea\FastFit\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettings.ps1'
. $scriptLocationPath
Import-Certificate -Filepath $CertificateFile -CertStoreLocation "Cert:\LocalMachine\Root"
## Server Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role server -Force

# Import NAV, cloud.ready and incadea modules
# To be able to import the moduel sqlps
# files had to be copied from folder "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules" to the folder "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" 
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -Force -WarningAction SilentlyContinue | out-null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1" -Force -WarningAction SilentlyContinue | Out-Null
Import-Module SQLPS -DisableNameChecking 
Import-module (Join-Path "$GitPath\Cloud.Ready.Software.PowerShell\PSModules" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-module (Join-Path "$GitPath\IncadeaNorway" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
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
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER2DB -DatabaseServer $DBServer -DatabaseName $DEALER2DBNameNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileMASTERDB -DatabaseServer $DBServer -DatabaseName $MASTERDBNameNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileREPORTINGDB -DatabaseServer $DBServer -DatabaseName $REPORTINGDBNameNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileSTAGINGDB -DatabaseServer $DBServer -DatabaseName $STAGINGDBNameNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileTEMPLATEDB -DatabaseServer $DBServer -DatabaseName $TEMPLATEDBNameNO
# Restore DEV and Demo databases
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoDBNO  -DatabaseServer $DBServer -DatabaseName $DemoDBNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileAppDB -DatabaseServer $DBServer -DatabaseName $AppDBNameNODev
Restore-SQLBackupFile-INC -BackupFile $BackupfileDEALER1DB -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNODev 
# Backup the development database that will be upgraded
$BackupFileName = $UpgradeFromDevDBName + "_BeforeUpgradeTo$UpradeFromVersion.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeFromDevDBName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Remember to manually add the NAV Instance user as DBOwner for all databases
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $AppDBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DEALER2DBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $MASTERDBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $REPORTINGDBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $STAGINGDBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $TEMPLATEDBNameW1 -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DemoDBW1 -DatabaseUser $DBNAVServiceUserName 
# NO
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $AppDBNameNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DEALER2DBNameNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $MASTERDBNameNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $REPORTINGDBNameNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $STAGINGDBNameNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $TEMPLATEDBNameNO -DatabaseUser $DBNAVServiceUserName 
# Dev
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DemoDBNO -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $AppDBNameNODev -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNODev -DatabaseUser $DBNAVServiceUserName 
 
# Creating Credential for the NAV Server Instance user
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName , $InstanceSecurePassword 
# Creating NAV Server Instances
Write-host "Create Service Instance"
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstanceW1 -DatabaseServer $DBServer
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstance -DatabaseServer $DBServer
New-NAVEnvironment  -EnablePortSharing -ServerInstance $FastFitInstanceDev -DatabaseServer $DBServer
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
Write-host "Mount Tenants W1"
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $DEALER1DBNameW1 -Id $Dealer1TenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $DEALER2DBNameW1 -Id $Dealer2TenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $MASTERDBNameW1 -Id $MASTERTenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $REPORTINGDBNameW1 -Id $REPORTINGTenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $STAGINGDBNameW1 -Id $STAGINGTenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceW1 -DatabaseName $TEMPLATEDBNameW1 -Id $TEMPLATETenantW1 -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Write-host "Mount Tenants NO"
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $DEALER1DBNameNO -Id $Dealer1TenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $DEALER2DBNameNO -Id $Dealer2TenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $MASTERDBNameNO -Id $MASTERTenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $REPORTINGDBNameNO -Id $REPORTINGTenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $STAGINGDBNameNO -Id $STAGINGTenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $FastFitInstanceNO -DatabaseName $TEMPLATEDBNameNO -Id $TEMPLATETenantNO -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Write-host "Mount Tenants Dev"
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
# Add user to W1 database
New-NAVUser-INC -NavServiceInstance $FastFitInstanceW1 -User $UserName -Tenant $Dealer1TenantW1
# Add user to NO database
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $Dealer1TenantNO
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $Dealer2TenantNO
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $MASTERTenantNO
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $REPORTINGTenantNO
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $STAGINGTenantNO
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNO -User $UserName -Tenant $TEMPLATETenantNO
# Add user to Dev database
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNODev -User $UserName -Tenant $Dealer1TenantNO
New-NAVUser-INC -NavServiceInstance $FastFitInstanceUpgradeFromVersionW1 -User $UserName -Tenant $Dealer1TenantW1

# Make the development environment a single tenant
Write-Host "Starting merging $AppDBNameNODev and $DEALER1DBNameNODev to single tenant." -foregroundcolor cyan 
# Stop the server instance if it is running.
Set-NAVServerInstance -ServerInstance $FastFitInstanceNODev -Stop
# Remove any application tables from the tenant database if these have not already been removed
Remove-NAVApplication -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNODev -Force
# and Copy the application tables from the application database to the tenant database.
Export-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBNameNODev -DestinationDatabaseName $DEALER1DBNameNODev -Force
# Reconfigure the CustomSettings.config to use the tenant database.
Set-NAVServerConfiguration -ServerInstance $FastFitInstanceNODev -KeyName DatabaseName -KeyValue $DEALER1DBNameNODev -WarningAction Ignore
# Reconfigure the CustomSettings.config to use single-tenant mode
Set-NAVServerConfiguration -ServerInstance $FastFitInstanceNODev -KeyName Multitenant -KeyValue false -WarningAction Ignore
# Start the server instance.
Set-NAVServerInstance -ServerInstance $FastFitInstanceNODev -Start
# Delete the App database
Remove-SQLDatabase -DatabaseServer $DBServer -DatabaseName $AppDBNameNODev
# Dismount all tenants that are not using the current tenant database.
# Get-NAVTenant -ServerInstance $FastFitInstanceNODev | where {$_.Database -ne $DEALER1DBNameNODev} | foreach { Dismount-NAVTenant -ServerInstance $FastFitInstanceNODev -Tenant $_.Id }
# Adding user to the database
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNODev -User $DBNAVServiceUserName 
New-NAVUser-INC -NavServiceInstance $FastFitInstanceNODev -User $UserName
$CurrentServerInstanceNODev = Get-NAVServerInstance -ServerInstance $FastFitInstanceNODev
$CurrentServerInstanceNODev | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstanceNODev | Set-NAVServerInstance -Restart
Write-Host "Finished merging databases to single tenant. The single tenant database name is $DEALER1DBNameNODev." -foregroundcolor cyan 
# Export all objects to text files. Remember that the objects will be created on the $NAVServer.
# To be able to export the object file, a correct zup file for finsql.exe has to be copied. It points to DB, Server Instance and tenant.
Copy-Item -Path (join-path (join-path $NAVEnvZupFilePath $UpgradeFromW1DBName) 'fin.zup') -Destination $NAVZupFilePath -Force
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeFromW1DBName -Path $OriginalObjectsPath -LogPath $LogPath -ExportTxtSkipUnlicensed
Copy-Item -Path (join-path (join-path $NAVEnvZupFilePath $UpgradeFromDevDBName) 'fin.zup') -Destination $NAVZupFilePath -Force
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeFromDevDBName -Path $FastFitObjectsPath -LogPath $LogPath -ExportTxtSkipUnlicensed
Copy-Item -Path (join-path (join-path $NAVEnvZupFilePath $DEALER1DBNameNODev) 'fin.zup') -Destination $NAVZupFilePath -Force
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNODev -Path $TargetObjectsPath -LogPath $LogPath -ExportTxtSkipUnlicensed
Copy-Item -Path (join-path (join-path $NAVEnvZupFilePath $DemoDBNO) 'fin.zup') -Destination $NAVZupFilePath -Force
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $DemoDBNO -Path $DemoObjectsNOPath -LogPath $LogPath -ExportTxtSkipUnlicensed
# Copy from remote server
Copy-Item -Path $OriginalObjectsPath -Destination (Join-Path $ClientWorkingFolder $OriginalObjects) -Force
Copy-Item -Path $FastFitObjectsPath -Destination (Join-Path $ClientWorkingFolder $FastFitObjects) -Force
Copy-Item -Path $TargetObjectsPath -Destination (Join-Path $ClientWorkingFolder $TargetObjects) -Force
Copy-Item -Path $DemoObjectsNOPath -Destination (Join-Path $ClientWorkingFolder $DemoObjectsNO) -Force
# Merge Customer database objects and NAV 2016 objects.
# I got out of memory error on the $NAVServer, so I copied the files and run the merge code from NO01DEVTS02.si-dev.local server.
Remove-Item -Path "$MergeResultPath\*.*"
Remove-Item -Path "$MergedPath\*.*"
Remove-Item -Path "$ToBeJoinedPath\*.*"
# Export DEU Language from Target file
Export-NAVApplicationObjectLanguage -Source $TargetObjectsPath -LanguageId "DEU" -Destination $LangFileDEU
# Export "NOR" and "ENU"  Language from Modified file
Export-NAVApplicationObjectLanguage -Source $FastFitObjectsPath -LanguageId "NOR" -Destination $LangFileNOR
Export-NAVApplicationObjectLanguage -Source $FastFitObjectsPath -LanguageId "ENU" -Destination $LangFileENU
# Importing DEU to modifed file
Import-NAVApplicationObjectLanguage -Source $FastFitObjectsPath -LanguageId "DEU" -LanguagePath $LangFileDEU -Destination $FastFitObjectsWithENUNORDEUPath
Import-NAVApplicationObjectLanguage -Source $DemoObjectsNOPath -LanguageId "DEU" -LanguagePath $LangFileDEU -Destination $DemoObjectsWithENUNORDEUPath
# Removing "NOR" and "ENU"  Language from Modified file
Remove-NAVApplicationObjectLanguage -Source $FastFitObjectsWithENUNORDEUPath -LanguageId "NOR","ENU" -Destination $FastFitObjectsWithDEUPath
Remove-NAVApplicationObjectLanguage -Source $DemoObjectsWithENUNORDEUPath -LanguageId "NOR","ENU" -Destination $DemoObjectsDEUOnlyPath

$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjectsPath `    -ModifiedObjects $FastFitObjectsWithDEUPath `
    -TargetObjects $TargetObjectsPath `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force
# Splitting Original, Modified and Target files to individua files.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjectsPath -ModifiedFileName $FastFitObjectsPath -TargetFileName $TargetObjectsPath -CompareObject $CompareObject -Split
# Copy object files with conflict to the Merged folder
# Copy merged result items to the Merged/ToBeJoined folder. Subfolders are not included in the search.
Compare-Folders -WorkingFolderPath $WorkingFolder -CompareFolder1Path $MergeResultPath -CompareFolder2Path $TargetPath -CompareObjectFilter $CompareObjectFilter `
                -CopyMergeResult2ToBeJoined -MoveConflictItemsFromToBeJoined2Merged -CompareContent -DropObjectProperty 
# Remove Original standard objects that have been removed or that we do not have license to import to DB as text files
Remove-OriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -WriteResultToFile
# Join ToBeJoined folder
Join-NAVApplicationObjectFile -Source $ToBeJoinedPath  -Destination $ToBeJoinedDestinationFile -Force  
# Compare the $ToBeJoinedDestinationFile file to the $TargetObjects in the "NAV Object Compare" application from Rune Sigurdsen
$NAVObjectCompareWinClient = join-path 'C:\Users\DevJAL\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\NAVObjectCompareWinClient' 'NAVObjectCompareWinClient.appref-ms'
& $NAVObjectCompareWinClient  

# Copy file with merged objects to NAV Server
Copy-Item -Path (join-path $ClientWorkingFolder $JoinFileName ) -Destination $JoinFile -Force
# Import the objects to the development database
Import-NAVApplicationObject2 -Path $JoinFile -ServerInstance $FastFitInstanceNODev -ImportAction Overwrite -LogPath $LogPath -NavServerName $NAVServer -SynchronizeSchemaChanges Force
# Compile objects and fix all errors
Compile-NAVApplicationObject2 -ServerInstance $FastFitInstanceNODev -LogPath $LogPath -SynchronizeSchemaChanges Yes
# Export new object file with merged objects
Copy-Item -Path (join-path (join-path $NAVEnvZupFilePath $DEALER1DBNameNODev) 'fin.zup') -Destination $NAVZupFilePath -Force
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $DEALER1DBNameNODev -Path $JoinFile -LogPath $LogPath -ExportTxtSkipUnlicensed
# Importing DEU,NOR and ENU to merged objects file
Import-NAVApplicationObjectLanguage -Source $JoinFile -LanguageId "DEU" -LanguagePath $LangFileDEU -Destination $FastFitDevObjectsWithENUNORDEUPath
Import-NAVApplicationObjectLanguage -Source $FastFitDevObjectsWithENUNORDEUPath -LanguageId "NOR" -LanguagePath $LangFileNOR -Destination $FastFitDevObjectsWithENUNORDEUPath
Import-NAVApplicationObjectLanguage -Source $FastFitDevObjectsWithENUNORDEUPath -LanguageId "ENU" -LanguagePath $LangFileENU -Destination $FastFitDevObjectsWithENUNORDEUPath
# Import the objects with ENU and NOR language to the development database
Import-NAVApplicationObject2 -Path $FastFitDevObjectsWithENUNORDEUPath -ServerInstance $FastFitInstanceNODev -ImportAction Overwrite -LogPath $LogPath -NavServerName $NAVServer -SynchronizeSchemaChanges Yes
# Copy file with merged objects and languages from NAV Server
Copy-Item -Path $FastFitDevObjectsWithENUNORDEUPath -Destination (join-path $ClientWorkingFolder $FastFitDevObjectsENUNORDEU) -Force
Copy-Item -Path (join-path $ClientWorkingFolder $FastFitDevObjectsENUNORDEU) -Destination $FastFitDevObjectsWithENUNORDEUPath -Force
# Compile objects and fix all errors
Compile-NAVApplicationObject2 -ServerInstance $FastFitInstanceNODev -LogPath $LogPath -SynchronizeSchemaChanges Yes
#Create Web client instance
New-NAVWebServerInstance -WebServerInstance $FastFitInstanceNO  -Server $NAVServer -ServerInstance $FastFitInstanceNO 
New-NAVWebServerInstance -WebServerInstance $FastFitInstanceNODev  -Server $NAVServer -ServerInstance $FastFitInstanceNODev 
# Backup
$BackupFileName = $DEALER1DBNameNODev + "_AfterMergeAndLanguageImport.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $DEALER1DBNameNODev -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
