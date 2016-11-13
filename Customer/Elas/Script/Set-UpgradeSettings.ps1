#Base Path
#Azure
#$RootFolderPath = "F:\NavUpgrade"
#SQLNAVUpgrade
$RootFolderPath = "F:\NavUpgrade"
#Servers
$DBServer = 'localhost'
$NAVServer = 'localhost'
#NAV Specific data
$NAVShortVersion = '100'
$DBServer = "SQLNAVUpgrade"
$NavServiceInstance = "DynamicsNAV100"
$NavServiceInstanceServer = "SQLNAVUpgrade"
$NAVVersion = '2017'
$NAVCU = 'CU0'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVInstallConfigFile = "C:\GitHub\NAVUpgrade\NAVSetup\FullInstallNAV2016.xml"
$NAVLicense = "$RootFolderPath\License\NAV2017.flf"
#$CUDownloadFile = 'C:\Temp\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe'
$ZippedDVDfile  = "$RootFolderPath\NAV\NAV2016\Temp\490370_NOR_i386_zip.exe"
#Company data
$CompanyName = 'Elas'
$UpgradeName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName
$UpgradeDataBaseName = 'NAV100CU0Elas'
$UpgradeObjectsName = 'NAV' + $NAVShortVersion  + $NAVCU + $CompanyName + 'Objects'
$CompanyFolder = "$CompanyName\NAV$NAVVersion\$NAVCU"
$ModifiedFolder = "$RootFolderPath\Customer\$CompanyName\CustomerDBs"
$ModifiedObjectFile = 'NAV50SP1Elas.txt'
$WorkingFolder = "$RootFolderPath\Customer\$CompanyFolder\Upgrade_$UpgradeName"
$WorkingFolderNAV2009 = "$RootFolderPath\Customer\$CompanyFolder\NAV2009"
$WorkingFolderNAV2015 = "$RootFolderPath\Customer\$CompanyFolder\NAV2015"
#Original DB objects
$ObjectLibrary = "$RootFolderPath\DB Original"
#Database backup files
$BackupPath = $ModifiedFolder
$BackupfileCaompanyDB = join-path $ModifiedFolder 'NAV50ToBeUpgraded111116.bak'
$BackupfileTargetDB = "$RootFolderPath\NAV\NAV2016\NAV2016NO5_45243\DVD\NAV.9.0.45243.NO.DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\90\Database\Demo Database NAV (9-0).bak"
$NAV2009BackupFile = "$RootFolderPath\NAV\NAV2009\DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\60\Database\Demo Database NAV (6-0).bak"
$NAV2015BackupFile = "$RootFolderPath\NAV\NAV2015\CU24\DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\80\Database\Demo Database NAV (8-0).bak"
#Previous NAv versions naming
$NAV2009DBName = 'NAV60' + $CompanyName 
$NAV2015CU = 'CU24'
$NAV2009ObjectFile = 'NAV2009_R2_35179_NO.txt'
$NAV2015DBName = 'NAV80' + $NAV2015CU + $CompanyName
$NAV2015ObjectFile = 'NAV2015_' +$NAV2015CU  + '_NO.txt'
$NAV2015ModifiedObjectFile = 'Elas_NAV2009_WithMerged_Tables.txt'
#Upgrade objects 
$NAV2015APPObjects2Import = join-path $WorkingFolderNAV2015 ($CompanyName +'_NAV2015' +$NAV2015CU  + 'NO.fob')
$NAV2015UpgradeObjects2Import= join-path $WorkingFolderNAV2015 'Upgrade601800.NO.fob'
$NAV2017APPObjects2Import = join-path $WorkingFolder ($CompanyName +'_NAV' + $NAVVersion + '_' + $NAVCU + '_' + 'NO.fob')
$NAV2017UpgradeObjects2Import= join-path $WorkingFolder 'Upgrade8001000.NO.fob'
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
$OriginalVersion = 'NAV40_SP1_NO'
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
