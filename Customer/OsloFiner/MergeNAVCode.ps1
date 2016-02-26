$ScriptPath = "C:\Users\$env:Username\OneDrive for Business\Files\NAV\Script\"
#Import-Module "$ScriptPath\Function\Enums.ps1" -Verbose
#Import-Module "$ScriptPath\Function\UpgradeNAVCode.ps1" -Verbose
#Import-Module "$ScriptPath\Function\RestoreDBFromFile.ps1"
Import-Module (join-path $ScriptPath Function\Functions.psm1) -DisableNameChecking -Force  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Import-module Function -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue


$dbName = "NAV2016CU4_OsloFiner"
$DBServer = "jalw8.si-data.no"
$RootFolderPath = "C:\NavUpgrade\"
$BackupPath = "E:\Backup\Navision Demo\"
$BackupFileName = "Demo Database NAV (9-0) CU4.bak"
$CompanyFolderName = "OsloFiner"
$CompanyOriginalFileName = "NAV_2015_41370.txt"
$CompanyModifiedFileName = "OsloFiner_NAV_2015_41370.txt"
$CompanyTargetFileName = "NAV_2016_CU4_NO_AllObjects.txt"
$LicensFile = "C:\NAVUpgrade\License\SI-Data 06082015.flf"
$Version = '9'
#$CompareObject = "TAB*.TXT"
$CompareObject = "*.TXT"
$RootFolder = "C:\NAVUpgrade\$CompanyFolderName"
$LogPath = "$RootFolder\Logs\"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"
$NAVAPPObjects2Import = "$RootFolder\all-merged-objects.txt"
$NavServiceInstance = "NAV90_OsloFiner"
$FirstPort = 7980

$BackupFilePath = $BackupPath + $BackupFileName 

[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split

#Clear-Host

UpgradeNAVCode -RootFolderPath $RootFolderPath  -CompanyFolderName $CompanyFolderName -Version $Version `
                -CompanyOriginalFileName $CompanyOriginalFileName -CompanyModifiedFileName $CompanyModifiedFileName `
                -CompanyTargetFileName $CompanyTargetFileName -UpgradeAction $UpgradeAction -CompareObject $CompareObject

$UpgradeAction = [UpgradeAction]::Merge
UpgradeNAVCode -RootFolderPath $RootFolderPath  -CompanyFolderName $CompanyFolderName -Version $Version `
                -CompanyOriginalFileName $CompanyOriginalFileName -CompanyModifiedFileName $CompanyModifiedFileName `
                -CompanyTargetFileName $CompanyTargetFileName -UpgradeAction $UpgradeAction `
                -CompareObject $CompareObject
                #-CompareObject $CompareObject -OpenConflictFilesInKdiff $True 

$UpgradeAction = [UpgradeAction]::Join
UpgradeNAVCode -RootFolderPath $RootFolderPath  -CompanyFolderName $CompanyFolderName -Version $Version `
                -CompanyOriginalFileName $CompanyOriginalFileName -CompanyModifiedFileName $CompanyModifiedFileName `
                -CompanyTargetFileName $CompanyTargetFileName -UpgradeAction $UpgradeAction `
                -CompareObject $CompareObject -RemoveOriginalFilesNotInTarget $True -RemoveModifyFilesNotInTarget $True
                #-CompareObject $CompareObject


RestoreDBFromFile -backupFile $BackupFilePath -dbNewname $dbName

#SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "NT-MYNDIGHET\NETTVERKSTJENESTE"
SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "SI-Data\SQL"

CreateNAVServerInstance -DBServer $DBServer -DataBase $dbName -FirstPortNumber $FirstPort -NavServiceInstance $NavServiceInstance
CreateNavUser -User si-data\jal -NavServiceInstance $NavServiceInstance 

#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance 
Import-NAVServerLicense $NavServiceInstance  -LicenseData ([Byte[]]$(Get-Content -Path $LicensFile -Encoding Byte))
#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance -Database $dbName -Force

Import-NAVApplicationObject $NAVAPPObjects2Import -DatabaseServer $DBServer -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose

Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No


