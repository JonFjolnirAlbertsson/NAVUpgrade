#NAV Specific data
$NAVShortVersion = '71'
$NAVVersion = '2013R2'
$NAVCU = 'CU19'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
#Company data
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
$UpdateNo = '20160831'
$UpdateFileName = '20160810_MC_All_V4.txt'
#General
$UpgradeRootFolder = 'C:\NAVUpgrade\Customer'
$INCUpdateFolder = "Merge"
$CompanyFolder = "$CompanyName"
$ObjectFolderPath = join-path $UpgradeRootFolder "$CompanyFolder\$INCUpdateFolder"
$WorkingFolder = join-path $ObjectFolderPath $UpgradeName
$NAVLicense = 'C:\NAVUpgrade\License\NAV2016.flf'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'

$ImportLog = join-path $WorkingFolder 'Log'
$ConversionLog = join-path $WorkingFolder 'Log'

#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'

#Original Version
$OriginalVersion = 'NAV2013R2_CU19.txt'
$OriginalObjects = join-path $ObjectFolderPath  $OriginalVersion
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedFolder = join-path $WorkingFolder 'Modified'
$ModifiedServerInstance = $UpgradeName
$ModifiedObjects = join-path $ObjectFolderPath $UpdateFileName

#Target Version
$TargetVersion = $OriginalVersion
$TargetServerInstance = $UpgradeName
$TargetObjects = join-path $ObjectFolderPath $TargetVersion
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
