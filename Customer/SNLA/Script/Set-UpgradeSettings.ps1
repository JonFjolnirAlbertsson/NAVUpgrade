#Base Path
$RootFolderPath = "C:\NavUpgrade"
#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'
#NAV Specific data
$NAVShortVersion = '90'
$DBServer = "SQLNAVUpgrade"
$NavServiceInstance = "DynamicsNAV90"
$NavServiceInstanceServer = "SQLNAVUpgrade"
$NAVVersion = '2016'
$NAVCU = 'CU5'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVInstallConfigFile = "C:\GitHub\NAVUpgrade\NAVSetup\FullInstallNAV2016.xml"
$NAVLicense = "$RootFolderPath\License\NAV2016.flf"
$UpgradeCodeunitsFullPath = 'F:\UpgradeToolKit\Local Objects\Upgrade800900.NO.fob'
#$CUDownloadFile = 'C:\Temp\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe'
$ZippedDVDfile  = "$RootFolderPath\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe"
#Company data
$CompanyName = 'SNLA'
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
$UpgradeObjectsName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName + 'Objects'
$CompanyFolder = "$CompanyName\NAV2016\$NAVCU"
$ModifiedFolder = "$RootFolderPath\Customer\$CompanyName\CustomerDBs"
$ModifiedObjectFile = 'SNLA_NAV2015_CU8_NO.txt'
$WorkingFolder = "$RootFolderPath\Customer\$CompanyFolder\Upgrade_$UpgradeName"
$WorkingFolderNAV2009 = "$RootFolderPath\Customer\$CompanyFolder\NAV2009"
$WorkingFolderNAV2015 = "$RootFolderPath\Customer\$CompanyFolder\NAV2015"
#Original DB objects
$ObjectLibrary = "$RootFolderPath\DB Original"
#Database backup files
$BackupfileCaompanyDB = join-path $ModifiedFolder 'Navision50_30032016.bak'
$BackupfileTargetDB = "$RootFolderPath\NAV\NAV2016\NAV2016NO5_45243\DVD\NAV.9.0.45243.NO.DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\90\Database\Demo Database NAV (9-0).bak"
$NAV2009BackupFile = "$RootFolderPath\NAV\NAV2009\DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\60\Database\Demo Database NAV (6-0).bak"
$NAV2015BackupFile = "$RootFolderPath\NAV\NAV2015\CU17\DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\80\Database\Demo Database NAV (8-0).bak"

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
$OriginalVersion = 'NAV2015_CU8_NO'
$OriginalObjects = join-path $ObjectLibrary "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedServerInstance = $UpgradeName
$ModifiedObjects = join-path $ModifiedFolder $ModifiedObjectFile
$ModifiedDatabaseBackupLocation = join-path $ModifiedFolder "$($ModifiedServerInstance).bak"
$ModifiedFolder = join-path $WorkingFolder 'Modified'
$ModifiedNAV2015Objects = join-path $WorkingFolderNAV2009 $NAV2015ModifiedObjectFile

#Target Version
$TargetVersion = 'NAV' + $NAVVersion + '_' + $NAVCU + '_NO' 
$TargetServerInstance = 'DynamicsNAV90'
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'
$TargetNAV2009Objects = join-path $ObjectLibrary $NAV2009ObjectFile
$TargetNAV2015Objects = join-path $ObjectLibrary $NAV2015ObjectFile

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
