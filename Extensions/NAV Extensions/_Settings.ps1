#The app
$AppName = 'Demo'
$AppPublisher = 'Incadea Norge AS'
$AppDescription = 'DemoNAVPadApp'
$InitialAppVersion = '1.0.0.0'
$IncludeFilesInNavApp = ''

#The build environment
$WorkingFolder = 'C:\NAVUpgrade\Extension\_Workingfolder'

$OriginalServerInstance = "Shared_ORIG"
$ModifiedServerInstanceV1 = "$($AppName)_DEV_V1"
$ModifiedServerInstanceV2 = "$($AppName)_DEV_V2"
$TargetServerInstance = "Shared_TEST"
$TargetTenant = 'Default'
$License = "C:\NAVUpgrade\License\NAV2016.flf"
$ISVNumberRangeLowestNumber = 82100

#Defaults
$DefaultServerInstance = 'DynamicsNAV100'
$NavAppWorkingFolder = join-path $WorkingFolder $AppName
$BackupPath = [io.path]::GetFullPath((Join-Path $PSScriptRoot '\..\'))