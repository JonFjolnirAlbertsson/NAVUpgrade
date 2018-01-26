#Base Path
<<<<<<< HEAD
$RootFolderPath = Join-Path (Split-Path $psise.CurrentFile.FullPath -Qualifier) 'incadea'
=======
$RootFolderPath = Join-Path (Get-Location).providerpath 'incadea'
$CompanyName = 'PP'
>>>>>>> 9ef08e1c78fec3c4a78c7319bb50dfefded54641
#Servers
$DBServer = 'NO01DEVSQL01'
$NAVServer = 'NO01DEV03'
$DBServer = 'localhost'
$NAVServer = 'localhost'
# Database
$UpgradeDataBaseName = 'NAV2009R2_PP_ToUpgrade'
$BackupPath = Join-Path (Get-Location).providerpath  'Backup'
#NAV Specific data
$NAVShortVersion = 'NAV110'
$NavServiceInstance = "NAV110_$CompanyName"
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
