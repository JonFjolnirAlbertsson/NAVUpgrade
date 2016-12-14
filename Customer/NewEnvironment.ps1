$DefaultServerInstance = 'DynamicsNAV100'
$NewServerInstance = 'NAV100Photocure'
$License = 'C:\NAVUpgrade\License\NAV2016.flf'
#Change the name of the Demo DB to reference the CU number
$InstallConfig = 'C:\GitHub\NAVUpgrade\NAVSetup\FullInstallNAV2017.xml'
$CopyFromServerInstance = Get-NAVServerInstance $DefaultServerInstance -ErrorAction Stop

#$Backupfile = $CopyFromServerInstance | Backup-NAVDatabase -ErrorAction Stop
#$CopyFromServerInstance | Enable-NAVServerInstancePortSharing
$Backupfile = 'C:\Temp\NAV\NAV2013R2\CU29_NO_45254\DVD\NAV.7.1.45254.NO.DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\71\Database\Demo Database NAV (7-1).bak'
$NAVVersion = '2017'
$CountryCode = 'NO'
$DownloadFolder = 'C:\Temp\NAV'
$DVDDestination = "C:\Temp\NAV\NAV$NAVVersion"
$TmpLocation ='C:\Temp\NAV\NAV\Temp'
$ISODir = 'C:\Temp\NAV\NAV\ISO'
$LogFile = 'C:\Temp'
$Download = Get-NAVCumulativeUpdateFile -versions $NAVVersion  -CountryCode $CountryCode -DownloadFolder $DownloadFolder

$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath $Download.filename
#$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath 'C:\Temp\NAV\NAV2017\NAV.10.0.14199.NO.DVD.zip'
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath 'C:\Temp\NAV\NAV2017\NAV.10.0.14199.NO.DVD.zip' -TmpLocation $TmpLocation -IsoDirectory $ISODir 
$InstallationPath = Unzip-NAVCumulativeUpdateDownload -SourcePath $ZippedDVDfile -DestinationPath $DVDDestination

$InstallationResult = Install-NAV -DVDFolder $InstallationPath -Configfile $InstallConfig
#$InstallationResult = Install-NAV -DVDFolder 'C:\Temp\NAV\NAV\Temp\NAV.10.0.14199.NO.DVD' -Configfile $InstallConfig -Log $LogFile
#MODIFIED (DEV)
#Restore-SQLBackupFile-SID -BackupFile $Backupfile -DatabaseName 'Demo Database NAV (7-1) CU29'
New-NAVEnvironment -ServerInstance $NewServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License
