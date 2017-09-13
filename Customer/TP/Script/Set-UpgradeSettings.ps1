#Base Path
$RootFolderPath = "C:\incadea"
#Servers
$DBServer = 'NO01DEVSQL01'
$NAVServer = 'NO01DEV03'
#NAV Specific data
$NAVShortVersion = 'NAV90'
$NavServiceInstance = "DynamicsNAV90"
$NAVVersion = 'NAV2017'
$NAVCU = 'CU03'
$FastFitNAVCU = 'CU17'
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\NAV2017.flf"
#$UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$DBUser = 'NAV_Service'
#Company data
$CompanyName = 'TP'
$CompanyFolder = join-path 'Customer' $CompanyName
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
#Original DB objects
#$ObjectLibrary = "$RootFolderPath\DB Original"
$ObjectLibrary = "$RootFolder\DB Original"

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
$OriginalVersion = 'NAV 20174 CU03 CustomerObjects'
$OriginalObjects = join-path $ObjectLibrary "$($OriginalVersion).txt"
$OriginalFolder = join-path $WorkingFolder 'Original'

#Modified Version
$ModifiedVersion = 'NAV 20174 CU06 ICA'
$ModifiedObjects = join-path $ObjectLibrary "$($ModifiedVersion).txt"
$ModifiedFolder = join-path $WorkingFolder 'Modified'

#Target Version
$TargetVersion= 'NAV 20174 CU03 CustomerObjects'
$TargetObjects = join-path $ObjectLibrary "$($TargetVersion).txt"
$TargetFolder = join-path $WorkingFolder 'Target'

#Result Version
$ResultObjectFile = Join-Path $WorkingFolder 'Result.fob'

#Join
$JoinFolder = join-path $WorkingFolder 'Merged\ToBeJoined'
$DestinationFile = join-path $WorkingFolder "$ModifiedServerInstance.txt"
