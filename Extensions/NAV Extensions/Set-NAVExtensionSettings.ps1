#The app
$AppName = 'SID_DemoExt'
$AppPublisher = 'SI-Data'
$AppDescription = 'SI-Data Extension Demo'
$InitialAppVersion = '1.0.0.0'

#The build environment
$WorkingFolder = 'C:\NAVUpgrade\Extension'

$OriginalServerInstance = "$($AppName)_Original"
$ModifiedServerInstance = "$($AppName)_DEV"
$TargetServerInstance = "$($AppName)_QA"
$TargetTenant = 'Default'
#$License = 'C:\NAVUpgrade\License\SI-Data.flf'
#$License = ''

#Defaults
$DefaultServerInstance = 'DynamicsNAV90'
$NavAppWorkingFolder = join-path $WorkingFolder $AppName
$BackupModifiedObjectsPath = Join-Path $NavAppWorkingFolder 'BackupObjects'
$BackupCloudFolder = 'E:\Backup\SI-Data\Extension'