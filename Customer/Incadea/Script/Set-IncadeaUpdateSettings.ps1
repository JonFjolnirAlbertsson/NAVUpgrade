﻿#NAV Specific data
$NAVShortVersion = '71'
$NAVVersion = '2013R2'
$NAVCU = 'CU29'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
#Company data
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
$UpdateNo = '14'
$UpdateFileName = 'Changesv14.txt'
#General
$UpgradeRootFolder = 'C:\NAVUpgrade\Customer'
$INCUpdateFolder = "Incadea\FOB\Update$UpdateNo"
$CompanyFolder = "$CompanyName\NAV$NAVVersion\$NAVCU"
$ObjectFolderPath = "$UpgradeRootFolder\$CompanyFolder\$INCUpdateFolder"
$WorkingFolder = "$ObjectFolderPath\$UpgradeName"
$NAVLicense = 'C:\NAVUpgrade\License\NAV2016.flf'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'

$ImportLog = join-path $WorkingFolder 'Log'
$ConversionLog = join-path $WorkingFolder 'Log'

#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'

#Original Version
$OriginalVersion = $UpgradeName
$OriginalObjects = join-path $ObjectFolderPath  "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedFolder = join-path $WorkingFolder 'Modified'
$ModifiedServerInstance = $UpgradeName
$ModifiedObjects = join-path $ObjectFolderPath $UpdateFileName

#Target Version
$TargetVersion = $UpgradeName
$TargetServerInstance = 'NAV71SIData'
$TargetObjects = join-path $ObjectFolderPath "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
