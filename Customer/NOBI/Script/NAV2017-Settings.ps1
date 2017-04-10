#Base Path
$RootFolderPath = "C:\NavUpgrade"
#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'
#NAV Specific data
$NAVShortVersion = '100'
$NavServiceInstance = "DynamicsNAV100"
$NAVVersion = '2017'
$NAVCU = 'CU04'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\NAV2017.flf"

#Company data
$CompanyName = 'NOBI'
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
$UpgradeDataBaseName = 'NAV100NOBI'
$UpgradeObjectsName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName + 'Objects'
$CompanyFolder = "$CompanyName\NAV2017\$NAVCU"
$ModifiedFolder = "$RootFolderPath\Customer\$CompanyName\CustomerDBs"
$ModifiedObjectFile = 'NAV2017_CU00_NOBI.txt'
$WorkingFolder = "$RootFolderPath\Customer\$CompanyFolder\Upgrade_$UpgradeName"
#Original DB objects
$ObjectLibrary = "$RootFolderPath\DB Original"
#Database backup files
$BackupPath = $ModifiedFolder
$BackupfileOriginalDB = join-path $ModifiedFolder 'Demo Database NAV (9-0).bak'
$BackupfileTargetDB = 'F:\Incadea\Backup\Navision Demo\Demo Database NAV (10-0) CU04.bak'
#Putting the paths toghether
$RootFolder = $RootFolderPath + $CompanyFolderName
$LogPath = "$RootFolder\Logs\"
$CompileLog = $LogPath + "compile"
$ImportLog = $LogPath + "import"
$ConversionLog = $LogPath + "Conversion"
$TmpLocation = "$NAVRootFolder\Temp\"
$ISODir = "$NAVRootFolder\ISO"
$NAVRootFolder = "$RootFolderPath\NAV\NAV$NAVVersion"
$InstallLogFolder = "$NAVRootFolder\Log"
$InstallLog = "$InstallLogFolder\install.log"

#Original Version
$OriginalVersion = 'NAV2017_CU00_NO'
$OriginalObjects = join-path $ObjectLibrary "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedServerInstance = $UpgradeName
$ModifiedObjects = join-path $ModifiedFolder $ModifiedObjectFile
$ModifiedDatabaseBackupLocation = join-path $ModifiedFolder "$($ModifiedServerInstance).bak"
$ModifiedFolder = join-path $WorkingFolder 'Modified'

#Target Version
$TargetVersion = 'NAV' + $NAVVersion + '_' + $NAVCU + '_NO' 
$TargetServerInstance = 'DynamicsNAV100'
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
