$ScriptPath = "C:\Users\jal\OneDrive for Business\Files\NAV\Script"
Import-Module "$ScriptPath\Function\SQLRestoreFromFile.ps1"
Import-Module "$ScriptPath\Function\SQLRenameLogicalFileName.ps1"
Import-Module "$ScriptPath\Function\SQLChangeCompatibilityLevel.ps1"
Import-Module "$ScriptPath\Function\SQLEnableBroker.ps1"
Import-Module "$ScriptPath\Function\SQLSetServiceInstanceUserPermission.ps1"
Import-Module "$ScriptPath\Function\CreateNAVServerInstance.ps1"
Import-Module "$ScriptPath\Function\CreateNAVUser.ps1"
Import-Module "$ScriptPath\Function\Start-NAVApplicationObjectInWindowsClient.ps1"

$dbName = "NAV2016CU1_OSO"
$DBServer = "localhost"
$BackupPath = "F:\SQLBackup\OSO\UpgradeProcess\"
$NavServiceInstance = "NAV80_OSO"
$FirstPort = 7790
$CompanyFolderName = "OSO"
$RootFolder = "C:\NAVUpgrade\$CompanyFolderName"
$LogPath = "$RootFolder\Logs\"
$LicensFile = "C:\NAVUpgrade\License\SI-Data 06082015.flf"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"

$NAVAPPObjects2Import = "$RootFolder\OSO_NAV_2016_CU1_NO_AllObjects.fob"
$NAVUpgradeAPPObjects2Import = "$RootFolder\Upgrade800900.NO.fob"

# Check if folders exists. If not create them.
if(!(Test-Path -Path $BackupPath )){
    New-Item -ItemType directory -Path $BackupPath
}

# Restore DB from Customer
#$BackupFileName = "Demo Database NAV (8-0) CU1.bak"
#$BackupFilePath = "F:\SQL\Backup\Navision Demo\" + $BackupFileName 
#RestoreDBFromFile -backupFile $BackupFilePath -dbNewname "Demo Database NAV (8-0) CU1"
#Export-NAVApplicationObject -DatabaseName $BackupFileName -Path $RootFolder\NAV_2015_CU1_NO_AllObjects.txt -DatabaseServer $DBServer

#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance

#Convert Database to NAV 2016 CU1
Invoke-NAVDatabaseConversion -DatabaseName $dbName -DatabaseServer $DBServer -LogPath $ConversionLog

# Step 6
$BackupFileName = $dbName + "_Step6.bak"
$BackupFilePath = $BackupPath + $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $dbName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseName $dbName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 

# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseName $dbName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# NAV 2015
#SetNAVServiceUserPermission -DBName $dbName -ADUser "NT-MYNDIGHET\NETTVERKSTJENESTE"
SetNAVServiceUserPermission -DBName $dbName -ADUser "NT AUTHORITY\NETWORK SERVICE"

#CreateNAVServerInstance -DataBase "NAV2016CU1_BuschObject" -DBServer $DBServer -FirstPortNumber 7910 -NavServiceInstance "NAV90_BuschObject" 
CreateNAVServerInstance -DataBase $dbName -DBServer $DBServer -FirstPortNumber $FirstPort -NavServiceInstance $NavServiceInstance

# Import Migrated NAV 2015 objects with SI-Data migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAVAPPObjects2Import -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2015 upgrade objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAVUpgradeAPPObjects2Import -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
# Import Migrated NAV 2015 upgrade objects. Synchronize Schema option to Later.
#Import-NAVApplicationObject $NAV2015UpgradeAPPObjects2ChangedImport -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose

# Compile all objects which have not been compiled. Synchronize Schema option to Later.
#yes, no, 1, 0
#$Filter = 'Compiled=0'
#Compile-NAVApplicationObject -DatabaseName $dbName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# Compile all objects
Compile-NAVApplicationObject -DatabaseName $dbName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# Force compile of these tables
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseName $dbName -DatabaseServer $DBServer -NavServerName $DBServer -Filter $Filter -NavServerInstance $NavServiceInstance -NavServerManagementPort $FirstPort -Recompile -SynchronizeSchemaChanges Force

#Compile these object with force, we expect loss of this data.
#$Filter = 'ID=10604'
#Compile-NAVApplicationObject -DatabaseName $dbName -DatabaseServer $DBServer -NavServerName $DBServer -Filter $Filter -NavServerInstance $NavServiceInstance -NavServerManagementPort $FirstPort -Recompile -SynchronizeSchemaChanges Force

# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $NavServiceInstance -Mode Sync
Sync-NAVTenant -ServerInstance $NavServiceInstance -Mode CheckOnly

#Step 7
$BackupFileName = $dbName + "_Step7.bak"
$BackupFilePath = $BackupPath + $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $dbName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default


# Start Data upgrade NAV 2015
#Start-NAVDataUpgrade -ServerInstance $NavServiceInstance -FunctionExecutionMode Parallel
#Test purpose
Start-NAVDataUpgrade -ServerInstance $NavServiceInstance -FunctionExecutionMode Serial
#Resume-NAVDataUpgrade -CodeunitId 104055 -CompanyName "FilteruniQ AS" -FunctionName StartUPgrade -ServerInstance $NavServiceInstance

# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Progress
Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | ogv
#Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -Detailed | Out-File 
Get-NAVDataUpgrade -ServerInstance $NavServiceInstance -ErrorOnly | ogv

Resume-NAVDataUpgrade -ServerInstance $NavServiceInstance

#Step 8
$BackupFileName = $dbName + "_Step8.bak"
$BackupFilePath = $BackupPath + $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $dbName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

# If NAV 2015 dataupgrade fails and you need to go back to the state before upgrade
<#
Set-NAVServerInstance -ServerInstance $NavServiceInstance -Stop
#Remove-NAVServerInstance -ServerInstance $NavServiceInstance
$BackupFileName = $dbName + "_Step4.bak"
$BackupFilePath = $BackupPath + $BackupFileName 
RestoreDBFromFile -backupFile $BackupFilePath -dbNewname $dbName
Set-NAVServerInstance -ServerInstance $NavServiceInstance -Start
#>

#Open Table "Temp Item Empty BUoM"
#Start-NAVApplicationObjectInWindowsClient -ServerInstance $NavServiceInstance -Port ($FirstPort+1) -ObjectType Table -ObjectID 104076 -Verbose

# Import users, role and company
# Setup profiler for users.

# Delete the Upgrade Objects and Obsolete Tables
$Filter = 'Version List=UPGTK9*'
Delete-NAVApplicationObject -DatabaseName $dbName -DatabaseServer $DBServer -Filter $Filter -LogPath $ImportLog -NavServerInstance $NavServiceInstance -NavServerManagementPort $FirstPort -NavServerName $DBServer -SynchronizeSchemaChanges Force

# Database backup with upgraded data and Control Add-Ins
#Step 9
$BackupFileName = $dbName + "_Step9.bak"
$BackupFilePath = $BackupPath + $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $dbName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default

#Export-NAVApplicationObject -DatabaseName $dbName -Path "C:\NAVUpgrade\SI-Data NAV 2015\NAV 2015 CU8\Data\si-data" -DatabaseServer $DBServer -LogPath "C:\NAVUpgrade\SI-Data NAV 2015\NAV 2015 CU8\Data\"
#Export-NAVData -CompanyName "SI-DATA København A/S" -FilePath $NAV2015ApplicationDataBackup -ServerInstance $NavServiceInstance -Description "SI-Data backup" -Force -IncludeApplication -IncludeApplicationData -IncludeGlobalData
Export-NAVData -AllCompanies -FilePath $NAV2015ApplicationDataBackup -ServerInstance $NavServiceInstance -Description "SI-Data backup" -Force -IncludeApplication -IncludeApplicationData -IncludeGlobalData

#Export-NAVData -AllCompaniesExport-NAVData -DatabaseName $dbName -FilePath $NAV2015ApplicationDataBackup -CompanyName "SI-DATA København A/S" -DatabaseServer $DBServer -IncludeApplication -IncludeApplicationData -IncludeGlobalData