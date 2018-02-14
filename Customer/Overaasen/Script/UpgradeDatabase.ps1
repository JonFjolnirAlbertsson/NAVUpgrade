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

# Server Site script
clear-host
$StartedDateTime = Get-Date
Set-Location 'C:\'
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\Overaasen\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettings.ps1'
. $scriptLocationPath
Import-Certificate -Filepath $CertificateFile -CertStoreLocation "Cert:\LocalMachine\Root"
## Server Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role server -Force
# Creating Credential for the NAV Server Instance user
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName , $InstanceSecurePassword 

# Import NAV, cloud.ready and incadea modules. To be able to import the moduel sqlps
# files had to be copied from folder "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules" to the folder "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" 
Import-Module SQLPS -DisableNameChecking 
Import-module (Join-Path "$GitPath\Cloud.Ready.Software.PowerShell\PSModules" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-module (Join-Path "$GitPath\IncadeaNorway" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule 
# Create Customer Upgrade NAV NO database
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoDBNO  -DatabaseServer $DBServer -DatabaseName $DemoDBNO
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoDBNO  -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName
Restore-SQLBackupFile-INC -BackupFile $BackupfileDemoOriginalDBNO  -DatabaseServer $DBServer -DatabaseName $DemoOriginalDBNO
# Backup the development database that will be upgraded
if(!(Test-Path -Path $BackupPath )){
    New-Item -ItemType directory -Path $BackupPath
}
$BackupFileName = $UpgradeFromDataBaseName + "_BeforeUpgradeTo$UpgradeDataBaseName.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeFromDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Add the NAV Instance user as DBOwner for all databases
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DemoDBNO -DatabaseUser $DBNAVServiceUserName
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -DatabaseUser $DBNAVServiceUserName 
New-SQLUser-INC -DatabaseServer $DBServer -DatabaseName $DemoOriginalDBNO -DatabaseUser $DBNAVServiceUserName 
# Creating NAV Server Instances
Write-host "Create Service Instance"
New-NAVEnvironment  -EnablePortSharing -ServerInstance $UpgradeName  -DatabaseServer $DBServer
# Set instance to Multitenant
$CurrentServerInstance = Get-NAVServerInstance -ServerInstance $UpgradeName
Write-host "Set instance parameters"
# Set instance parameters
$CurrentServerInstance | Set-NAVServerInstance -stop
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "false"
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue $DBServer
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue $UpgradeName
$CurrentServerInstance | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentServerInstance | Set-NAVServerInstance -start
# Import License
$CurrentServerInstance | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentServerInstance | Set-NAVServerInstance -Restart
# Sync database
$CurrentServerInstance | Sync-NAVTenant -Mode Sync
# Add user to database
New-NAVUser-INC -NavServiceInstance $UpgradeName -User $UserName 
# Export all objects to text files. Remember that the objects will be created on the $NAVServer.
# Import Module for original DB
Import-NAVModules-INC -ShortVersion '100' -ServiceFolder 'Service CU03' -RTCFolder 'RTC CU03' -ImportRTCModule
New-NAVEnvironment  -EnablePortSharing -ServerInstance $UpgradeFromOriginalName  -DatabaseServer $DBServer
New-NAVUser-INC -NavServiceInstance $UpgradeFromOriginalName -User $DBNAVServiceUserName 
# Set instance parameters
$ServerInstanceOriginal = Get-NAVServerInstance -ServerInstance $UpgradeFromOriginalName
$ServerInstanceOriginal | Set-NAVServerInstance -stop
$ServerInstanceOriginal | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "false"
$ServerInstanceOriginal | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue $DBServer
$ServerInstanceOriginal | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue $DemoOriginalDBNO
$ServerInstanceOriginal | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$ServerInstanceOriginal | Set-NAVServerInstance -start
$ServerInstanceOriginal | Import-NAVServerLicense -LicenseFile $NAVLicense
$ServerInstanceOriginal | Set-NAVServerInstance -Restart
$ServerInstanceOriginal | Sync-NAVTenant -Mode Sync
#$ServerInstanceOriginal | Sync-NAVTenant -Mode ForceSync
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $DemoOriginalDBNO -Path $OriginalObjectsPath -Filter $ExportObjectFilter -LogPath $LogPath -ExportTxtSkipUnlicensed
# Import Module for Modified DB
Import-NAVModules-INC -ShortVersion '100' -ImportRTCModule
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeFromDataBaseName -Path $ModifiedObjectsPath -Filter $ExportObjectFilter -LogPath $LogPath -ExportTxtSkipUnlicensed
# Import Module for Target DB
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $DemoDBNO -Path $TargetObjectsPath -LogPath $LogPath -ExportTxtSkipUnlicensed
# Copy from remote server
if(!(Test-Path -Path $ClientWorkingFolder )){
    New-Item -ItemType directory -Path $ClientWorkingFolder
}
Copy-Item -Path $OriginalObjectsPath -Destination (Join-Path $ClientWorkingFolder $OriginalObjects) -Force
Copy-Item -Path $ModifiedObjectsPath -Destination (Join-Path $ClientWorkingFolder $ModifiedObjects) -Force
Copy-Item -Path $TargetObjectsPath -Destination (Join-Path $ClientWorkingFolder $TargetObjects) -Force
# Merge Customer database objects and NAV 2018 objects.
Remove-Item -Path "$MergeResultPath\*.*"
Remove-Item -Path "$MergedPath\*.*"
Remove-Item -Path "$ToBeJoinedPath\*.*"
Remove-Item -Path "$TargetPath\*.*"
Remove-Item -Path "$ModifiedPath\*.*"
# I got out of memory error on the $NAVServer, so I copied the files and run the merge code from NO01DEVTS02.si-dev.local server.
#winrm get winrm/config/winrs # Get memory size
#Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048 # Change memory size
#winrm set winrm/config/winrs `@`{MaxMemoryPerShellMB=`"2048`"`}
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjectsPath `    -ModifiedObjects $ModifiedObjectsPath `
    -TargetObjects $TargetObjectsPath `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force
# Splitting Original, Modified and Target files to individua files.
Merge-NAVCode-INC -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjectsPath -ModifiedFileName $ModifiedObjectsPath -TargetFileName $TargetObjectsPath -CompareObject $CompareObject -Split
# Copy object files with conflict to the Merged folder
# Copy merged result items to the Merged/ToBeJoined folder. Subfolders are not included in the search.
Compare-Folders -WorkingFolderPath $WorkingFolder -CompareFolder1Path $MergeResultPath -CompareFolder2Path $TargetPath -CompareObjectFilter $CompareObjectFilter `
                -CopyMergeResult2ToBeJoined -MoveConflictItemsFromToBeJoined2Merged -CompareContent -DropObjectProperty 
# Remove Original standard objects that have been removed or that we do not have license to import to DB as text files
Remove-OriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -WriteResultToFile
# Join ToBeJoined folder and not including files from Merged
Merge-NAVCode-INC -Join -WorkingFolderPath $WorkingFolder 
# Compare the $ToBeJoinedDestinationFile file to the $TargetObjects in the "NAV Object Compare" application from Rune Sigurdsen
$NAVObjectCompareWinClient = join-path 'C:\Users\DevJAL\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\NAVObjectCompareWinClient' 'NAVObjectCompareWinClient.appref-ms'
& $NAVObjectCompareWinClient  

# Join the Merged folder files without ToBeJoined and import to Dev database
Join-NAVApplicationObjectFile -Source (join-path $MergedPath $CompareObjectFilter)  -Destination $MergedFolderFile -Force  
# Copy file with merged objects to NAV Server
Copy-Item -Path (join-path $ClientWorkingFolder $JoinFileName) -Destination $JoinFile -Force
Copy-Item -Path (join-path $ClientWorkingFolder $MergedFolderFileName) -Destination $MergedFolderFile -Force
# Import the objects to the development database
Import-NAVApplicationObject2 -Path $MergedFolderFile -ServerInstance $UpgradeName -ImportAction Overwrite -LogPath $LogPath -NavServerName $NAVServer -SynchronizeSchemaChanges Force
Import-NAVApplicationObject2 -Path $JoinFile -ServerInstance $UpgradeName -ImportAction Overwrite -LogPath $LogPath -NavServerName $NAVServer -SynchronizeSchemaChanges Force
# Compile objects and fix all errors
Compile-NAVApplicationObject2 -ServerInstance $UpgradeName -LogPath $LogPath -SynchronizeSchemaChanges No
# Sync database
$CurrentServerInstance | Sync-NAVTenant -Mode Sync
$CurrentServerInstance | Sync-NAVTenant -Mode ForceSync
# Create Web client instance
New-NAVWebServerInstance -WebServerInstance $UpgradeName  -Server $NAVServer -ServerInstance $UpgradeName 
# Backup
$BackupFileName = $UpgradeName + "_AfterMerge.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Backup after all merging, import of OMA and test module
$BackupFileName = $UpgradeName + "_AfterMerge_WithOMA.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Export all application objects to Fob file without OMA and Test
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeName -Path $MergedFobFile -Filter $ExportObjectFilter -LogPath $LogPath -ExportTxtSkipUnlicensed
Copy-Item -Path $MergedFobFile -Destination (Join-Path $ClientWorkingFolder $MergedFobFileName) -Force

# Task 1: Prepare the old database
Import-NAVModules-INC -ShortVersion '100' -ImportRTCModule
$CurrentUpgradeFromInstance = Get-NAVServerInstance -ServerInstance $UpgradeFromInstance
$CurrentUpgradeFromInstance | Sync-NAVTenant -Mode Sync
# Task 2: Create a full SQL backup of the old database on SQL Server
$BackupFileName = $UpgradeFromDataBaseName + "_BeforeUpgrade.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
# Task 3 Uninstall all V1 extensions in old database
Get-NAVAppInfo -ServerInstance $UpgradeFromInstance | ft -AutoSize
Uninstall-NAVApp -ServerInstance $UpgradeFromInstance -Name 'Sales and Inventory Forecast' -Version 1.0.0.0
Uninstall-NAVApp -ServerInstance $UpgradeFromInstance -Name 'PayPal Payments Standard' -Version 1.0.0.0
# Task 4: Upload the Microsoft Dynamics NAV 2018 license to the old database
$CurrentUpgradeFromInstance | Import-NAVServerLicense -LicenseFile $NAVLicense
$CurrentUpgradeFromInstance | Set-NAVServerInstance -Restart
# Task 5: Delete all objects except tables from the old database
$Filter = 'Type=Codeunit|Page|Report|XMLport|Query'
Delete-NAVApplicationObject -DatabaseName $UpgradeFromDataBaseName -DatabaseServer $DBServer -Filter $Filter -SynchronizeSchemaChanges No
# Task 7: Clear Dynamics NAV Server instance records from old database
$CurrentUpgradeFromInstance | Set-NAVServerInstance -Stop
$SQLCommand = 'DELETE FROM [' + $UpgradeFromDataBaseName + '].[dbo].[Server Instance]'
Invoke-SQL-INC -DatabaseName $UpgradeName -DatabaseServer $DBServer -SQLCommand $SQLCommand -TimeOut 0 -TrustedConnection $True
$SQLCommand = 'DELETE FROM [' + $UpgradeFromDataBaseName + '].[dbo].[Debugger Breakpoint]'
Invoke-SQL-INC -DatabaseName $UpgradeName -DatabaseServer $DBServer -SQLCommand $SQLCommand -TimeOut 0 -TrustedConnection $True
# Task 8: Convert the old database to the Microsoft Dynamics NAV 2018 format
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule 
Invoke-NAVDatabaseConversion -DatabaseName $UpgradeFromDataBaseName -DatabaseServer $DBServer -LogPath $LogPath
# Task 9: Import the application objects to the converted database
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeFromDataBaseName -Path $MergedFobFile -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
$UpgradeFobFile = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\UpgradeToolKit\Local Objects\Upgrade10001100.NO.fob'
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeFromDataBaseName -Path $UpgradeFobFile -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
# Task 10: Connect a Microsoft Dynamics NAV 2018 Server instance to the converted database
Import-NAVModules-INC -ShortVersion '100' -ImportRTCModule
Remove-NAVServerInstance -ServerInstance $UpgradeFromInstance  -VERBOSE 
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule 
New-NAVEnvironment  -EnablePortSharing -ServerInstance $UpgradeFromInstance  -DatabaseServer $DBServer
#Restore-SQLBackupFile-INC -BackupFile $BackupFilePath  -DatabaseServer $DBServer -DatabaseName $UpgradeFromDataBaseName
# Set instance parameters
Get-NAVServerConfiguration -ServerInstance $UpgradeFromInstance
$CurrentUpgradeFromInstance = Get-NAVServerInstance -ServerInstance $UpgradeFromInstance
$CurrentUpgradeFromInstance | Set-NAVServerInstance -stop
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "false"
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue $DBServer
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue $UpgradeFromDataBaseName
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName SQLCommandTimeout -KeyValue 120
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName EnableSymbolLoadingAtServerStartup -KeyValue "true"
$CurrentUpgradeFromInstance | Set-NAVServerInstance -ServiceAccountCredential $InstanceCredential -ServiceAccount User
$CurrentUpgradeFromInstance | Set-NAVServerInstance -start
# Task 11: Compile all objects that are not already compiled
# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000000..2000000199'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -Recompile -SynchronizeSchemaChanges No
$Filter = 'Version List=*UPGTK*'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -Recompile -SynchronizeSchemaChanges No
$Filter = 'Compiled=Nei'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -SynchronizeSchemaChanges No
# Task 12: Recompile published extensions
Get-NAVAppInfo -ServerInstance $UpgradeFromInstance | Repair-NAVApp
# Task 13: Run the schema synchronization on the imported objects
$CurrentUpgradeFromInstance | Sync-NAVTenant -Mode Sync
# Task 14: Run the data upgrade process
$CurrentUpgradeFromInstance | Get-NAVServerConfiguration 
Start-NavDataUpgrade -ServerInstance $UpgradeFromInstance -FunctionExecutionMode Serial -SkipAppVersionCheck
Get-NAVDataUpgrade -ServerInstance $UpgradeFromInstance -Detailed
Get-NAVDataUpgradeContinuous -ServerInstance $UpgradeFromInstance
# Task 15: Delete the upgrade objects
$Filter = 'Version List=*UPGTK*'
Delete-NAVApplicationObject -DatabaseName $UpgradeFromDataBaseName -DatabaseServer $DBServer -Filter $Filter -SynchronizeSchemaChanges Force
# Task 16: Import upgraded permission sets and permissions by using the Roles and Permissions XMLports
# Manual import with XMLport from file
# Task 17: Set the language of the customer database
# In the development environment, choose Tools, choose Language, and then select the language of the original customer database
# Task 18: Register client control add-ins
# The database is now fully upgraded and is ready for use. However, Microsoft Dynamics NAV 2018 includes the following client control add-ins
#Task 19: Publish and install/upgrade extensions
$ModenDevFolder = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\ModernDev\program files\Microsoft Dynamics NAV\110\Modern Development Environment'
$SystemSymbolFile = join-path $ModenDevFolder 'System.app'
$TestSymbolFile = join-path $ModenDevFolder 'Test.app'
Publish-NAVApp -ServerInstance $UpgradeFromInstance -Path $SystemSymbolFile -PackageType SymbolsOnly
Publish-NAVApp -ServerInstance $UpgradeFromInstance -Path $TestSymbolFile -PackageType SymbolsOnly
$FinSQL = join-path 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client' 'finsql.exe'
& $FinSQL Command=generatesymbolreference, Database=$UpgradeFromDataBaseName, ServerName=$DBServer