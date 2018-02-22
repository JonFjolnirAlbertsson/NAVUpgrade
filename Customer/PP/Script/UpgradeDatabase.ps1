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
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\PP\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettings.ps1'
. $scriptLocationPath
## Server Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role server -Force
# Creating Credential for the NAV Server Instance user
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName, $InstanceSecurePassword 
Import-Module SQLPS -DisableNameChecking 
Import-module (Join-Path "$GitPath\Cloud.Ready.Software.PowerShell\PSModules" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-module (Join-Path "$GitPath\IncadeaNorway" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule 
#<#
# Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}
#>
# Merge Customer database objects and NAV 2018 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

# Split files, merge, compare and join to one file.
# Define Variablies
$CompareObjectFilter = '*.TXT'
$ResultFolderPath =  join-path $WorkingFolder 'Result'
$TargetFolderPath =  join-path $WorkingFolder 'Target'
$ResultMergedFolderPath =  join-path $ResultFolderPath 'Merged'
$MergedFolderPath =  join-path $WorkingFolder 'Merged'
$ToBeJoinedFolderPath = join-path $MergedFolderPath 'ToBeJoined'
$ResultDestinationFile = join-path $WorkingFolder 'Result_Objects.TXT'
$ToBeJoinedDestinationFile = join-path $WorkingFolder 'ToBeJoined_Objects.TXT'
# Split Original, Modified and Target object files
Merge-NAVCode-INC -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObjectFilter -Split
# Merge object file to new file in the Result folder
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObjectFilter -Merge
# Compare MergeResult (Waldo) and Result (Standard NAV) and write result to file
Compare-Folders -WorkingFolderPath $WorkingFolder -CompareObjectFilter $CompareObjectFilter -CopyMergeResult2ToBeJoined -MoveConflictItemsFromToBeJoined2Merged -CompareContent -CompareMergeResult2Result -DropObjectProperty 
# Remove Original standard objects that have been removed or that we do not have license to import to DB as text files
Remove-OriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -WriteResultToFile
# Join Result folder
Join-NAVApplicationObjectFile -Source $ResultMergedFolderPath  -Destination $ResultDestinationFile -Force
# Join ToBeJoined folder
Join-NAVApplicationObjectFile -Source $ToBeJoinedFolderPath  -Destination $ToBeJoinedDestinationFile -Force    
# Compare the $ToBeJoinedDestinationFile file to the $TargetObjects in the "NAV Object Compare" application from Rune Sigurdsen
$NAVObjectCompareWinClient = join-path 'C:\Users\DevJAL\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\NAVObjectCompareWinClient' 'NAVObjectCompareWinClient.appref-ms'
& $NAVObjectCompareWinClient 
# Count number of items in folder
$CompareObjectFilter = 'COD*.TXT'
Write-Host 'Comparing number of items' -ForegroundColor Green
Write-Host "Number of $CompareObjectFilter in $ToBeJoinedFolderPath" + (Get-ChildItem $ToBeJoinedFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
Write-Host "Number of $CompareObjectFilter in $TargetFolderPath" + (Get-ChildItem $TargetFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
$CompareObjectFilter = 'TAB*.TXT'
Write-Host "Number of $CompareObjectFilter in $ToBeJoinedFolderPath" + (Get-ChildItem $ToBeJoinedFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
Write-Host "Number of $CompareObjectFilter in $TargetFolderPath" + (Get-ChildItem $TargetFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
# Remember to manually compare the Merged objects with original, modified and target objects, before running this script.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

# Step 1
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step1.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow
#Restore-SQLBackupFile-INC -BackupFile $BackupFilePath   -DatabaseServer $DBServer -DatabaseName 'NAV2009R2_PP_Master'
#Step 2
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step2.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
# Step 3
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step3.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
# Step 4
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step4.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
# Sync and correct errors in NAV 2015
# Remember to load NAV 2015 modules
Import-NAVModules-INC -ShortVersion '80' -ImportRTCModule 
Sync-NAVTenant -ServerInstance $Nav2015ServiceInstance  -Mode Sync
# Step 5
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
# Start Data upgrade NAV 2015
Start-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -FunctionExecutionMode Serial

# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -Progress
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -Detailed | ogv
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -Detailed | Out-File 'C:\Incadea\Customer\PP\NAV2015UpgradeLog.txt'
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -ErrorOnly | ogv

Resume-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance

# Step 6
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step6.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 

# Start upgrading to NAV 2018
# Task 5: Delete all objects except tables from the old database
$Filter = 'Type=Codeunit|Page|Report|XMLport|Query'
Delete-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -Filter $Filter -SynchronizeSchemaChanges No
# Task 7: Clear Dynamics NAV Server instance records from old database
$CurrentUpgradeFromInstance = Get-NAVServerInstance -ServerInstance $Nav2015ServiceInstance
$CurrentUpgradeFromInstance | Set-NAVServerInstance -Stop
$SQLCommand = 'DELETE FROM [' + $UpgradeDataBaseName + '].[dbo].[Server Instance]'
Invoke-SQL-INC -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -SQLCommand $SQLCommand -TimeOut 0 -TrustedConnection $True
$SQLCommand = 'DELETE FROM [' + $UpgradeDataBaseName + '].[dbo].[Debugger Breakpoint]'
Invoke-SQL-INC -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -SQLCommand $SQLCommand -TimeOut 0 -TrustedConnection $True
# Using Dynamics NAV 2018
# Task 8: Convert the old database to the Microsoft Dynamics NAV 2018 format
Invoke-NAVDatabaseConversion -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -LogPath $LogPath
# Step 7
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step7.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 

# Task 9: Import the application objects to the converted database
$MergedFobFileName = 'NAV2018_CU01_NO_PP.fob'
$MergedFobFile = join-path $WorkingFolder $MergedFobFileName
if(!(Test-Path -Path $WorkingFolder )){
    New-Item -ItemType directory -Path $WorkingFolder
}
Copy-Item -Path (Join-Path $ClientWorkingFolder $MergedFobFileName) -Destination $MergedFobFile -Force
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Path $MergedFobFile -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
$UpgradeFobFile = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\UpgradeToolKit\Local Objects\Upgrade8001100.NO.fob'
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Path $UpgradeFobFile -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
# OMA Objects
$OMAFobFile = '\\NO01DEVSQL01\install\Tools\OMA\OMA12\OMA12 NAV2018.fob'
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Path $OMAFobFile -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
# Test Objects
$TestFobFile1 = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\TestToolKit\CALTestRunner.fob'
$TestFobFile2 = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\TestToolKit\CALTestLibraries.NO.fob'
$TestFobFile3 = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\TestToolKit\CALTestCodeunits.NO.fob'
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Path $TestFobFile1 -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Path $TestFobFile2 -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
Import-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Path $TestFobFile3 -ImportAction Overwrite -LogPath $LogPath -SynchronizeSchemaChanges No
# Task 10: Connect a Microsoft Dynamics NAV 2018 Server instance to the converted database
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule 
New-NAVEnvironment  -EnablePortSharing -ServerInstance $UpgradeFromInstance  -DatabaseServer $DBServer
#Restore-SQLBackupFile-INC -BackupFile $BackupFilePath  -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName
# Set instance parameters
Get-NAVServerConfiguration -ServerInstance $UpgradeFromInstance
$CurrentUpgradeFromInstance = Get-NAVServerInstance -ServerInstance $UpgradeFromInstance
$CurrentUpgradeFromInstance | Set-NAVServerInstance -stop
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "false"
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue $DBServer
$CurrentUpgradeFromInstance | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue $UpgradeDataBaseName
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
$Filter = 'Version List=*OMA*|*Test*'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -Recompile -SynchronizeSchemaChanges No
$Filter = 'Compiled=0'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -SynchronizeSchemaChanges No
# Task 12: Recompile published extensions
#Get-NAVAppInfo -ServerInstance $UpgradeFromInstance | Repair-NAVApp
# Task 13: Run the schema synchronization on the imported objects
$CurrentUpgradeFromInstance | Sync-NAVTenant -Mode Sync
#$CurrentUpgradeFromInstance | Sync-NAVTenant -Mode ForceSync
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -LogPath $LogPath -Recompile -SynchronizeSchemaChanges Yes
$Filter = 'Type=Table;Id=355|104050|104052|104055|104073..104075|104080|104089'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -Recompile -SynchronizeSchemaChanges Force
# Deleting objects from previous versions
$Filter = 'Type=Table;Id=239|470|680..685|824..830|150020..150027'
Delete-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeDataBaseName -Filter $Filter -LogPath $LogPath -SynchronizeSchemaChanges Force
$CurrentUpgradeFromInstance | Sync-NAVTenant -Mode Sync
# Step 8
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step8.bak"
#$BackupFileName = $UpgradeDataBaseName + "_Step8_1.bak" # Had to delete tables and merge because of error when running sync.
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
# Task 14: Run the data upgrade process
$CurrentUpgradeFromInstance | Get-NAVServerConfiguration 
Start-NavDataUpgrade -ServerInstance $UpgradeFromInstance -FunctionExecutionMode Serial
Get-NAVDataUpgrade -ServerInstance $UpgradeFromInstance -Detailed
Get-NAVDataUpgradeContinuous -ServerInstance $UpgradeFromInstance
# Step 9
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step9.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
# Task 15: Delete the upgrade objects
$Filter = 'Version List=*UPGTK*|Old Unused Table - marked for deletion.'
Delete-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -Filter $Filter -SynchronizeSchemaChanges Force
# Task 16: Import upgraded permission sets and permissions by using the Roles and Permissions XMLports
# Manual import with XMLport from file
# Task 17: Set the language of the customer database
# In the development environment, choose Tools, choose Language, and then select the language of the original customer database
# Task 18: Register client control add-ins
# The database is now fully upgraded and is ready for use. However, Microsoft Dynamics NAV 2018 includes the following client control add-ins
#Task 19: Publish and install/upgrade extensions
Get-NAVAppInfo -ServerInstance $UpgradeFromInstance
Uninstall-NAVApp -ServerInstance $UpgradeFromInstance -Name 'Sales and Inventory Forecast' -Version 1.0.0.0
Uninstall-NAVApp -ServerInstance $UpgradeFromInstance -Name 'PayPal Payments Standard' -Version 1.0.0.0
Unpublish-NAVApp -ServerInstance $UpgradeFromInstance -Name 'Sales and Inventory Forecast' -Version 1.0.0.0
Unpublish-NAVApp -ServerInstance $UpgradeFromInstance -Name 'PayPal Payments Standard' -Version 1.0.0.0
$ImageAnalysis = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\Extensions\ImageAnalysis\ImageAnalysis.app'
$MSWalletPayments = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\Extensions\MSWalletPayments\MSWalletPayments.navx'
$PayPalPaymentsStandard = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\Extensions\PayPalPaymentsStandard\PayPalPaymentsStandard.navx'
$SalesAndInventoryForecast = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\Extensions\SalesAndInventoryForecast\SalesAndInventoryForecast.navx'
Get-NAVAppInfo -ServerInstance $UpgradeFromInstance 
# Had to delete Test objects to be able to import the Image Analyzer extension
$Filter = 'Version List=*Test*'
Delete-NAVApplicationObject -DatabaseName $UpgradeDataBaseName -DatabaseServer $DBServer -Filter $Filter -SynchronizeSchemaChanges Force

$CurrentUpgradeFromInstance | Publish-NAVApp -Path $MSWalletPayments
$CurrentUpgradeFromInstance | Publish-NAVApp -Path $PayPalPaymentsStandard
$CurrentUpgradeFromInstance | Publish-NAVApp -Path $SalesAndInventoryForecast

Get-NAVAppInfo -ServerInstance $UpgradeFromInstance -SymbolsOnly
$ModenDevFolder = '\\NO01DEVSQL01\install\NAV2018\CU 02 NO\DVD\ModernDev\program files\Microsoft Dynamics NAV\110\Modern Development Environment'
$SystemSymbolFile = join-path $ModenDevFolder 'System.app'
$TestSymbolFile = join-path $ModenDevFolder 'Test.app'
Publish-NAVApp -ServerInstance $UpgradeFromInstance -Path $SystemSymbolFile -PackageType SymbolsOnly
Publish-NAVApp -ServerInstance $UpgradeFromInstance -Path $TestSymbolFile -PackageType SymbolsOnly

$FinSQL = join-path 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client' 'finsql.exe'
& $FinSQL Command=generatesymbolreference, Database=$UpgradeDataBaseName, ServerName=$DBServer

$CurrentUpgradeFromInstance | Publish-NAVApp -Path $ImageAnalysis
Sync-NAVApp -ServerInstance $UpgradeFromInstance -Name 'Image Analyzer' -Version 1.0.20348.0
# Create Web client instance
New-NAVWebServerInstance -WebServerInstance $UpgradeFromInstance  -Server $NAVServer -ServerInstance $UpgradeFromInstance 

# Backup Merged, OMA and upgraded DB
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_AfterUpgrade.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow
Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

