#Busch Vakuumteknikk

#Company Specific data
$dbName = "Demo Database NAV (7-1) CU29"

#$CompareObject = "TAB*.TXT"

#Common data
$RootFolderPath = "C:\NavUpgrade\"
$BackupPath = "E:\Backup\Navision Demo\"
$BackupFileName = 'Demo Database NAV (7-1) CU29.bak'
$CompanyFolderName = "Customer\SI-Data\NAV 2013 R2\CU29"
$LicensFile = "C:\NAVUpgrade\License\NAV2016.flf"

#NAV Specific data
$Version = '71'
$DBServer = "jalw8.si-data.no"
$NavServiceInstance = "DynamicsNAV71"
$NavServiceInstanceServer = "jalw8.si-data.no"
$NAVVersion = '2013R2'
$NAVInstallConfigFile = "C:\GitHub\NAVUpgrade\NAV2013R2\FullInstall.xml"

#Putting the paths toghether
$RootFolder = $RootFolderPath + $CompanyFolderName
$WorkingFolder = "$RootFolder\Upgrade_$UpgradeName"
$LogPath = "$RootFolder\Logs\"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"
$BackupFilePath = $BackupPath + $BackupFileName 
$TmpLocation = "$NAVRootFolder\Temp\"
$ISODir = "$NAVRootFolder\ISO"
$NAVRootFolder = "C:\Temp\NAV\NAV$NAVVersion"
$InstallLogFolder = "$NAVRootFolder\Log"
$InstallLog = "$InstallLogFolder\install.log"
