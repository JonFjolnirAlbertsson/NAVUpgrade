#Incadea object merge

$dbName = "NAV2015CU8_SIData"
$DBServer = "sql02.si-data.no"
$RootFolderPath = "C:\NavUpgrade\"
$BackupPath = "E:\Backup\Navision Demo\"
#$BackupFileName = "Demo Database NAV (9-0) CU4.bak"
$CompanyFolderName = "Customer\SI-Data\NAV 2016\Incadea"
$CompanyOriginalFileName = "2013_R2_CU10_NO_AllObjects.txt"
$CompanyModifiedFileName = "incadeaNAV.txt"
$CompanyTargetFileName = "SI-Data NAV2016CU4NO All Objects.txt"
$LicensFile = "C:\NAVUpgrade\License\NAV2016.flf"
$Version = '9'
#$CompareObject = "TAB*.TXT"
$CompareObject = "*.TXT"
$RootFolder = $RootFolderPath + $CompanyFolderName
$LogPath = "$RootFolder\Logs\"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"
$NAVAPPObjects2Import = "$RootFolder\all-merged-objects.txt"
$NavServiceInstance = "nav90sidataupgrade"
$NavServiceInstanceServer = "jalw8.si-data.no"
#$FirstPort = 7045

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
                #-CompareObject $CompareObject
                -CompareObject $CompareObject -OpenConflictFilesInKdiff $False

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


