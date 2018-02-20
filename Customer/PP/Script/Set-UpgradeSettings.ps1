#Base Path
$RootDrive = 'C:\'
$RootFolderName = 'incadea'
$RootFolderPath = join-path $RootDrive $RootFolderName
$CompanyName = 'PP'
$GitPath = join-path $RootDrive 'Git'
$DBServerRootPath = "\\NO01DEVSQL01\Backup\$CompanyName"
# Servers
$DBServer = 'NO01DEVSQL01.si-dev.local'
$NAVServer = 'NO01DEV03.si-dev.local'
$NAVServerRSName = 'NO01DEV03'
$NAVServerClientName = 'No01devts02'
$NAVLicense = join-path $RootFolderPath "License\NAV2018.flf"
$CertificateFile = join-path ("$GitPath\NAVUpgrade\Certificate") 'cert'
# Database
$UpgradeDataBaseName = 'NAV2009R2_PP_ToUpgrade'
$BackupPath = $DBServerRootPath
#NAV Specific data
$NAVShortVersion = 'NAV110'
$UpgradeFromInstance = "NAV110_$CompanyName"
$Nav2015ServiceInstance = "NAV80_$CompanyName"
$NAVVersion = 'NAV2018'
$NAVCU = 'CU01'
$NAVLandCode = 'NO'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\NAV2018.flf"
#$UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
#Company data
$CompanyFolder = join-path 'Customer' $CompanyName
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
$ObjectLibrary = "$RootFolder\DB"
#Original DB objects
$OriginalObjectLibrary = "$RootFolder\DB Original"
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
$OriginalVersion = '2009R2NO_6_00_32012_AllObjects'
$OriginalObjects = join-path  $OriginalObjectLibrary "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedVersion = 'NAV2009R2_' + $CompanyName
$ModifiedObjects = join-path $ObjectLibrary "$($ModifiedVersion).txt"
$ModifiedFolder = join-path $WorkingFolder 'Modified'

#Target Version
$TargetVersion= $NAVVersion + '_' + $NAVCU + '_' + $NAVLandCode
$TargetObjects = join-path $OriginalObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
