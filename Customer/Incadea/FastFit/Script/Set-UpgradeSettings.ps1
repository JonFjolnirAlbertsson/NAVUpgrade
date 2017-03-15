#Base Path
$RootFolderPath = "C:\NavUpgrade"
#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'
#NAV Specific data
$NAVShortVersion = 'NAV90'
$NavServiceInstance = "DynamicsNAV90"
$NAVVersion = 'NAV2016'
$NAVCU = 'CU17'
$FastFitNAVCU = 'CU04'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\NAV2017.flf"
$UserName = 'incadea\albertssonf'
#Company data
$CompanyName = 'FastFit'
$VersionFolder = 'fastfit_082000\incadeaFastfit_082001_W1'
$CompanyFolder = "Customer\Incadea\$CompanyName\$VersionFolder"
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
#Original DB objects
$ObjectLibrary = "$RootFolderPath\DB Original"
$ObjectLibraryW1 = "$RootFolderPath\DB Original\W1"
$ObjectLibraryNO = "$RootFolderPath\DB Original\NO"
#Database backup files
$BackupPath = join-path $RootFolder 'Database Backups'
$DemoDBName = 'Demo Database NAV (9-0) W1 CU04'
$TargetDemoDBName = 'Demo Database NAV (9-0) CU17'
$BackupfileNAVTargetDemoDB = join-path $ObjectLibraryNO 'Demo Database NAV (9-0) CU17.bak'
$BackupfileNAVDemoDB = join-path $ObjectLibraryW1 'Demo Database NAV (9-0) CU04.bak'
$BackupfileAppDB = join-path $BackupPath 'Fastfit_082001_W1_APP.bak'
$AppDBName = 'Fastfit_082001_W1_APP'
$BackupfileDEALER1DB = join-path $BackupPath 'Fastfit_082001_W1_DEALER1.bak'
$DEALER1DBName = 'Fastfit_082001_W1_DEALER1'
$Dealer1Tenant= 'default'
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
$FastFitObjects = join-path $RootFolder 'Installation\NAV Objects\incadea.fastfit 08.20.01 W1 All Objects.txt'
$FastFitFolder = join-path $WorkingFolder 'Modified'

#Target Version
$TargetVersion = $NAVVersion + '_' + $NAVCU + '_NO' 
$TargetServerInstance = $TargetVersion + '_' + $CompanyName
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
