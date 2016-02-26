#$ScriptPath = "C:\NAVUpgrade\Script"
$ScriptPath = "C:\Users\$env:Username\OneDrive for Business\Files\NAV\Script\"
<#
Import-Module "$ScriptPath\Function\RestoreDBFromFile.ps1"
Import-Module "$ScriptPath\Function\SQLRenameLogicalFileName.ps1"
Import-Module "$ScriptPath\Function\SQLChangeCompatibilityLevel.ps1"
Import-Module "$ScriptPath\Function\SQLEnableBroker.ps1"
Import-Module "$ScriptPath\Function\SQLSetServiceInstanceUserPermission.ps1"
Import-Module "$ScriptPath\Function\CreateNAVServerInstance.ps1"
Import-Module "$ScriptPath\Function\CreateNAVUser.ps1"
Import-Module "$ScriptPath\Function\Start-NAVApplicationObjectInWindowsClient.ps1"
#>
Import-Module (join-path $ScriptPath Function\Functions.psm1) -DisableNameChecking -Force  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Import-module Function -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

#$dbName = "NAV2016CU4_SIData"
$dbName = "NAV2016CU4_Busch"
#sql02.si-data.no:7086/nav80_sidata
$DBServer = "jalw8.si-data.no"
$BackupPath = "E:\Backup\Busch\NAV2016CU1_Busch\"
$BackupFileName = "NAV2016CU1_Busch.bak"
$NAVServerName = "jalw8.si-data.no"
$NavServiceInstance = "NAV90BuschCU4"
$FirstPort = 7965
$CompanyFolderName = "Busch\2016\CU4"
$RootFolder = "C:\NAVUpgrade\$CompanyFolderName"
$LogPath = "$RootFolder\Logs\"
$LicensFile = "C:\NAVUpgrade\License\SI-Data 06082015.flf"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"

$NAVAPPObjects2Import = "$RootFolder\Busch_NAV206CU4NO_AllObjects.fob"
$NAVUpgradeAPPObjects2Import = "$RootFolder\Upgrade800900.NO.fob"

# Check if folders exists. If not create them.
if(!(Test-Path -Path $BackupPath )){
    New-Item -ItemType directory -Path $BackupPath
}
if(!(Test-Path -Path $LogPath  )){
    New-Item -ItemType directory -Path $LogPath
}
# Restore DB from Customer
#$BackupFileName = "Demo Database NAV (9-0).bak"
$BackupFilePath = $BackupPath + $BackupFileName 
RestoreDBFromFile -backupFile $BackupFilePath -dbNewname $dbName

#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance

# Create NAV Server Instance for Objects database.
#$dbName = "NAV2016CU4_SIData"
#CreateNAVServerInstance -DataBase $dbName  -DBServer $DBServer -FirstPortNumber 7910 -NavServiceInstance "NAV90SIDataObjects" 

#Convert Database to NAV 2016 CU4
Invoke-NAVDatabaseConversion -DatabaseName $dbName -DatabaseServer $DBServer -LogPath $ConversionLog

#Delete all objects except tables
Delete-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -Filter 'Type=Codeunit|Page|Report|Query|XMLport|MenuSuite' 

# Compile system tables. Synchronize Schema option to Later.
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# NAV 2016
#SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "NT-MYNDIGHET\NETTVERKSTJENESTE"
SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "SI-Data\SQL"

CreateNAVServerInstance -DBServer $DBServer -DataBase $dbName -FirstPortNumber $FirstPort -NavServiceInstance $NavServiceInstance

# Import Migrated NAV 2016 objects with migrated objects. Synchronize Schema option to Later.
Import-NAVApplicationObject $NAVAPPObjects2Import -DatabaseServer $DBServer -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose

# Compile all objects which have not been compiled. Synchronize Schema option to Later.
#yes, no, 1, 0
#$Filter = 'Compiled=0'
#Compile-NAVApplicationObject -DatabaseName $dbName -Filter $Filter -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# Compile all objects
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

# Force compile of these tables
$Filter = 'ID=2000000004..2000000130'
Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -NavServerName $NAVServerName -Filter $Filter -NavServerInstance $NavServiceInstance -NavServerManagementPort $FirstPort -Recompile -SynchronizeSchemaChanges Force

#Compile these object with force, we expect loss of this data.
#$Filter = 'ID=10604'
#Compile-NAVApplicationObject -DatabaseName $dbName -DatabaseServer $DBServer -NavServerName $DBServer -Filter $Filter -NavServerInstance $NavServiceInstance -NavServerManagementPort $FirstPort -Recompile -SynchronizeSchemaChanges Force

# Synchronize all tables from the Tools menu by selecting Sync. Schema for All Tables, then With Validation.
Sync-NAVTenant -ServerInstance $NavServiceInstance -Mode Sync
Sync-NAVTenant -ServerInstance $NavServiceInstance -Mode CheckOnly
