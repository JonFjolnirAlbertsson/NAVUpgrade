# Base Variables
$RootDrive = 'C:\'
$RootFolderName = 'incadea'
$RootFolderPath = join-path $RootDrive $RootFolderName
$CompanyName = 'Overaasen'
$DBServerRootPath = "\\NO01DEVSQL01\Backup\$CompanyName"
$DBServerDemoPath = 'C:\MSSQL\Backup\Demo\'
$GitPath = join-path $RootDrive 'Git'
# Servers
$DBServer = 'NO01DEVSQL01.si-dev.local'
$NAVServer = 'NO01DEV03.si-dev.local'
$NAVServerRSName = 'NO01DEV03'
$NAVServerClientName = 'No01devts02'
$NAVLicense = join-path $RootFolderPath "License\NAV2018.flf"
$CertificateFile = join-path ("$GitPath\NAVUpgrade\Certificate") 'cert'
# $UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$DBNAVServiceUserName = 'si-dev\nav_user'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$DBUser = 'NAV_Service'
$NAVVersion = 'NAV2018'
$NAVShortVersion = 'NAV110'
$NAVCU = 'CU01'
# Company data
$CompanyFolder = "Customer\$CompanyName"
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
$ClientWorkingFolder = "\\$NAVServerClientName\c$\$RootFolderName\$CompanyFolder\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
$UpgradeName = $NAVShortVersion  + $NAVCU + '_' + $CompanyName
$UpgradeDataBaseName = $UpgradeName
$UpgradeFromOriginalName = 'NAV100CU3'
$UpgradeFromDataBaseName = $UpgradeFromOriginalName +'_' + $CompanyName
$UpgradeObjectsName = $NAVVersion  + $NAVCU + $CompanyName + 'Objects'																 
$LogPath = join-path $WorkingFolder 'Log'
# Database backup NO
$DemoOriginalDBNO = 'Demo Database NAV (10-0) NO CU03'
$DemoDBNO = 'Demo Database NAV (11-0) NO CU01'
# Database backup common
$BackupPath = $DBServerRootPath
$BackupfileDemoDBNO = join-path $DBServerDemoPath ("$DemoDBNO.bak")
$BackupfileDemoOriginalDBNO = join-path $DBServerDemoPath ("$DemoOriginalDBNO.bak")
# NAV Server Instances

# Merge files parameters
$OriginalObjects = $UpgradeFromOriginalName  + '_AllObjects.txt'$ModifiedObjects = $UpgradeFromDataBaseName + '_AllObjects.txt'
$TargetObjects = $NAVVersion +'_' + $NAVCU + '_NO.txt'
#$DemoObjectsNO = $NAVVersion +'_' + $NAVCU + '_NO.txt'
$OriginalObjectsPath = (join-path $WorkingFolder $OriginalObjects)
$ModifiedObjectsPath = (join-path $WorkingFolder $ModifiedObjects)
$TargetObjectsPath = (join-path $WorkingFolder $TargetObjects)
#$DemoObjectsNOPath = (join-path $WorkingFolder $DemoObjectsNO)
# Merging parameters
$VersionListPrefixes = 'NAVW1', 'NAVNO' #Needs full prefix definition Check in NAV DEV with (<>*IFFW*&<>*NAVW*&<>*NAVNO*)
$CompareObjectFilter = '*.TXT'
$MergeResultPath = join-path $WorkingFolder 'MergeResult' 
$ConflictTarget = join-path $MergeResultPath  'ConflictTarget' 
$MergedPath = join-path $WorkingFolder 'Merged' 
$ModifiedPath = join-path $WorkingFolder 'Modified' 
$TargetPath = join-path $WorkingFolder 'Target' 
$ToBeJoinedPath = Join-Path $MergedPath 'ToBeJoined'
$JoinFileName = 'all-merged-objects.txt'
$JoinFile = join-path $WorkingFolder $JoinFileName
$CopyResultFile =  join-path $WorkingFolder 'Copy Results.txt' 
$ToBeJoinedDestinationFile = join-path $WorkingFolder 'ToBeJoined_Objects.TXT'
