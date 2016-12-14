#Base Path
$RootFolderPath = "C:\NavUpgrade"
#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'
#NAV Specific data
$NAVShortVersion = '100'
$NavServiceInstance = "DynamicsNAV100"
$NAVVersion = '2017'
$NAVCU = 'CU0'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\NAV2017.flf"

#Company data
$CompanyName = 'NOBI'
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
$UpgradeDataBaseName = 'NAV90Elas'
$UpgradeObjectsName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName + 'Objects'
$CompanyFolder = "$CompanyName\NAV2017\$NAVCU"
$ModifiedFolder = "$RootFolderPath\Customer\$CompanyName\CustomerDBs"
$ModifiedObjectFile = 'NAV2016_CU9_NOBI.txt'
$WorkingFolder = "$RootFolderPath\Customer\$CompanyFolder\Upgrade_$UpgradeName"
#Original DB objects
$ObjectLibrary = "$RootFolderPath\DB Original"
#Database backup files
$BackupPath = $ModifiedFolder
$BackupfileOriginalDB = join-path $ModifiedFolder 'Demo Database NAV (9-0).bak'
$BackupfileTargetDB = 'E:\Backup\Navision Demo\Demo Database NAV (10-0).bak'
#Upgrade objects 
$NAV2017APPObjects2Import = join-path $WorkingFolder ($CompanyName +'_NAV' + $NAVVersion + '_' + $NAVCU + '_' + 'NO.fob')
$NAV2017UpgradeObjects2Import= join-path $WorkingFolder 'Upgrade9001000.NO.fob'
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
$OriginalVersion = 'NAV2016_CU9_NO'
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
