#General
$UpgradeName = 'NAV71CU29SIData'
$CompanyFolder = 'SI-Data\NAV 2013 R2\CU29'
$WorkingFolder = "C:\NAVUpgrade\Customer\$CompanyFolder\Upgrade_$UpgradeName"
$ObjectLibrary = 'C:\NAVUpgrade\DB Original'
$ModifiedFolder = "C:\NAVUpgrade\Customer\$CompanyFolder\CustomerDBs"
$NAVLicense = 'C:\NAVUpgrade\License\NAV2016.flf'
$UpgradeCodeunitsFullPath = 'E:\UpgradeToolKit\Local Objects\Upgrade800900.NO.fob'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$CUDownloadFile = 'C:\Temp\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe'
$IsoDirectory = 'C:\Temp\NAV\NAV2016\ISO'
#$ImportLog = join-path $WorkingFolder 'Log'

#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'

#Constants
$MergetoolPath     = 'C:\Program Files\KDiff3\kdiff3.exe'

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
