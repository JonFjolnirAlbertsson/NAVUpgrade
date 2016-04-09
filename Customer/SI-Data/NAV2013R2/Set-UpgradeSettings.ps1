#NAV Specific data
$NAVShortVersion = '71'
$NAVVersion = '2013R2'
$NAVCU = 'CU29'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
#General
$UpgradeName = 'NAV71CU29SIData'
$CompanyFolder = 'SI-Data\NAV2013R2\CU29'
$WorkingFolder = "C:\NAVUpgrade\Customer\$CompanyFolder\Upgrade_$UpgradeName"
$ObjectLibrary = 'C:\NAVUpgrade\DB Original'
$ModifiedFolder = "C:\NAVUpgrade\Customer\$CompanyFolder\CustomerDBs"
$NAVLicense = 'C:\NAVUpgrade\License\NAV2016.flf'
$UpgradeCodeunitsFullPath = 'E:\UpgradeToolKit\Local Objects\Upgrade800900.NO.fob'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$CUDownloadFile = 'C:\Temp\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe'
$IsoDirectory = 'C:\Temp\NAV\NAV2016\ISO'
$ImportLog = join-path $WorkingFolder 'Log'
$ConversionLog = join-path $WorkingFolder 'Log'
#Company data
$CompanyName = 'SIData'
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'
#Database backup files
$BackupPath = 'E:\Backup\SI-Data\UpgradeProcess'
$BackupfileCaompanyDB = join-path 'E:\Backup\SI-Data\SQL02' 'Nav50_02042016.bak'

#Original Version
$OriginalVersion = 'NAV2016_CU4_NO'
$OriginalObjects = join-path $ObjectLibrary "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedServerInstance = $UpgradeName
$ModifiedObjects = join-path $ModifiedFolder "$($ModifiedServerInstance).txt"
$ModifiedDatabaseBackupLocation = join-path $ModifiedFolder "$($ModifiedServerInstance).bak"
$ModifiedFolder = join-path $WorkingFolder 'Modified'

#Target Version
$TargetVersion = 'NAV2013_R2_CU29' 
$TargetServerInstance = 'DynamicsNAV71'
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
