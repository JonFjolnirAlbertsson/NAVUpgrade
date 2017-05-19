#Base Path
$RootFolderPath = "C:\incadea"
#Servers
$DBServer = 'NO01DEVSQL01'
$NAVServer = 'NO01DEV03'
#NAV Specific data
$NAVShortVersion = 'NAV90'
$NavServiceInstance = "DynamicsNAV90"
$NAVVersion = 'NAV2016'
$NAVCU = 'CU17'
$FastFitNAVCU = 'CU17'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\incadea.fastfit_8.X (NAV2016)_development_INS-NOR_4805448_20170321.flf"
#$UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$DBUser = 'NAV_Service'
#Company data
$CompanyName = 'Fastfit'
$VersionFolder = '083000'
$CompanyFolder = "$CompanyName\$VersionFolder"
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
#Original DB objects
$ObjectLibrary = "$RootFolderPath\DB Original"
$ObjectLibraryW1 = "$RootFolderPath\DB Original\W1"
$ObjectLibraryNO = "$RootFolderPath\DB Original\NO"
#Database backup files
$BackupPath = join-path $RootFolder 'Database Backups'
$DemoDBName = 'Demo Database NAV (9-0) CU17 W1'
$TargetDemoDBName = 'Demo Database NAV (9-0) CU17 NO'
$BackupfileNAVTargetDemoDB = join-path $ObjectLibraryNO 'Demo Database NAV (9-0) CU17.bak'
$BackupfileNAVDemoDB = join-path $ObjectLibraryW1 'Demo Database NAV (9-0) CU17.bak'
$AppDBName = 'fastfit_083000_NO_APP'
$AppDBNameW1 = 'fastfit_083000_W1_APP'
$BackupfileAppDB = join-path $BackupPath 'fastfit_083000_W1_APP.bak'
$DEALER1DBName = 'fastfit_083000_NO_DEALER1'
$DEALER1DBNameW1 = 'fastfit_083000_W1_DEALER1'
$BackupfileDEALER1DB = join-path $BackupPath 'fastfit_083000_W1_DEALER1.bak'
$Dealer1Tenant= 'dealer1'
$Dealer1TenantW1= 'dealer1w1'
$FastFitInstance = 'fastfit_083000_NO'
$FastFitInstanceDev = 'fastfit_083000_NO_Dev'
$FastFitInstanceW1 = 'fastfit_083000_W1'

#Merging parameters
$SourcePath = join-path $WorkingFolder 'MergeResult' 
$ConflictTarget = join-path $SourcePath  'ConflictTarget' 
$MergedPath = join-path $WorkingFolder 'Merged' 
$JoinPath = Join-Path $WorkingFolder 'Merged\ToBeJoined\'
$JoinFile = join-path $WorkingFolder 'all-merged-objects.txt'
#Putting the paths toghether
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
$OriginalVersion = $NAVVersion + '_' + $FastFitNAVCU + '_W1'
$OriginalObjects = join-path $ObjectLibrary "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$FastFitServerInstance = $UpgradeName
$FastFitObjects = join-path $RootFolder 'Installation\NAV Objects\incadea.fastfit 08.30.00 W1 All Objects Excluded DEU.txt'
$FastFitFolder = join-path $WorkingFolder 'Modified'

#Target Version
$TargetVersion = $NAVVersion + '_' + $NAVCU + '_NO' + '_Without_NOR'
$TargetServerInstance = $TargetVersion + '_' + $CompanyName
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
