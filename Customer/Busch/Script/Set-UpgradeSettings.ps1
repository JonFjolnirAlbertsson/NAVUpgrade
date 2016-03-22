#General
$UpgradeName = 'NAV90CU5Busch'
$WorkingFolder = "C:\NAVUpgrade\Customer\Busch\2016\CU5\Upgrade_$UpgradeName"
$ObjectLibrary = 'C:\NAVUpgrade\DB Original'
$ModifiedFolder = 'C:\NAVUpgrade\Customer\Busch\2016\CU5\CustomerDBs'
$NAVLicense = 'C:\NAVUpgrade\License\NAV2016.flf'
$UpgradeCodeunitsFullPath = 'E:\UpgradeToolKit\Local Objects\Upgrade800900.NO.fob'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$CUDownloadFile = 'C:\Temp\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe'
$IsoDirectory = 'C:\Temp\NAV\NAV2016\ISO'

#Original Version
$OriginalVersion = 'NAV2016_CU1_NO'
$OriginalObjects = join-path $ObjectLibrary "$($OriginalVersion).txt"

#Modified Version
$ModifiedServerInstance = $UpgradeName
$ModifiedObjects = join-path $ModifiedFolder "$($ModifiedServerInstance).txt"
$ModifiedDatabaseBackupLocation = join-path $ModifiedFolder "$($ModifiedServerInstance).bak"

#Target Version
$TargetVersion = 'NAV2016_CU5' 
$TargetServerInstance = 'DynamicsNAV90'
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'








#Target Version
$TargetVersion = 'DISTRI91' 
$TargetServerInstance = 'DynamicsNAV90'
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

