#Busch Vakuumteknikk

#Company Specific data
$dbName = "NAV2016CU5_SIData"


#Merge Files and information
$CompanyOriginalFileName = "NAV2016_CU4_NO_AllObjects.txt"
$CompanyModifiedFileName = "Busch NAV216 All changed objects.txt"
$CompanyTargetFileName = "NAV2016_CU5_NO_AllObjects.txt"
$CompareObject = "*.TXT"
#$CompareObject = "TAB*.TXT"

#Common data
$RootFolderPath = "C:\NavUpgrade\"
$BackupPath = "E:\Backup\Navision Demo\"
$BackupFileName = 'Demo Database NAV (9-0) CU5.bak'
$CompanyFolderName = "Customer\Busch\2016\CU5"
$LicensFile = "C:\NAVUpgrade\License\NAV2016.flf"
$NAVRootFolder = "C:\Temp\NAV\NAV$NAVVersion"

#NAV Specific data
$Version = '9'
$DBServer = "jalw8.si-data.no"
$NavServiceInstance = "nav90sidataupgrade"
$NavServiceInstanceServer = "jalw8.si-data.no"
$NAVVersion = 2016
$NAVInstallConfigFile = "C:\NAV Setup\NAV2016\FullInstallNAV2016.xml"

#Putting the paths toghether
$RootFolder = $RootFolderPath + $CompanyFolderName
$LogPath = "$RootFolder\Logs\"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"
$BackupFilePath = $BackupPath + $BackupFileName 
$TmpLocation = "$NAVRootFolder\Temp\"
$ISODir = "$NAVRootFolder\ISO"
$InstallLog = "$NAVRootFolder\Log\install.log"