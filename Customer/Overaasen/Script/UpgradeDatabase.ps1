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

# Import NAV, cloud.ready and incadea modules
# To be able to import the moduel sqlps
# files had to be copied from folder "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules" to the folder "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" 
#Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -Force -WarningAction SilentlyContinue | out-null
#Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1" -Force -WarningAction SilentlyContinue | Out-Null
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
# Creating Credential for the NAV Server Instance user
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName , $InstanceSecurePassword 
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
#Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\100\Service CU03\NavAdminTool.ps1" -Force -WarningAction SilentlyContinue | Out-Null
#Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\100\RTC CU03\Microsoft.Dynamics.Nav.Model.Tools.psd1" -Force -WarningAction SilentlyContinue | out-null
Import-NAVModules-INC -ShortVersion '100' -ServiceFolder 'Service CU03' -RTCFolder 'RTC CU03' -ImportRTCModule

New-NAVEnvironment  -EnablePortSharing -ServerInstance $UpgradeFromOriginalName  -DatabaseServer $DBServer
New-NAVUser-INC -NavServiceInstance $UpgradeFromOriginalName -User $DBNAVServiceUserName 
#$ServerInstanceOriginal = Get-NAVServerInstance -ServerInstance 'nav100_overaasen'
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
#Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\100\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -Force -WarningAction SilentlyContinue | out-null
#Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1" -Force -WarningAction SilentlyContinue | Out-Null
Import-NAVModules-INC -ShortVersion '100' -ImportRTCModule
Export-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeFromDataBaseName -Path $ModifiedObjectsPath -Filter $ExportObjectFilter -LogPath $LogPath -ExportTxtSkipUnlicensed
# Import Module for Target DB
#Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -Force -WarningAction SilentlyContinue | out-null
#Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1" -Force -WarningAction SilentlyContinue | Out-Null
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
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjectsPath -ModifiedFileName $ModifiedObjectsPath -TargetFileName $TargetObjectsPath -CompareObject $CompareObject -Split
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
