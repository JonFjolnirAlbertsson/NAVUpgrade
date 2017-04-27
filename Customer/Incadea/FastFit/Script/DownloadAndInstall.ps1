#We only need to run this if we want ISO file
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 
$DefaultServerInstance = 'DynamicsNAV90'
$License = 'C:\NAVUpgrade\License\NAV2017.flf'
#Change the name of the Demo DB to reference the CU number
$InstallConfig = 'C:\GitHub\NAVUpgrade\NAVSetup\FullInstallNAV2017.xml'


#$Backupfile = $CopyFromServerInstance | Backup-NAVDatabase -ErrorAction Stop
#$CopyFromServerInstance | Enable-NAVServerInstancePortSharing
#$Backupfile = 'C:\Temp\NAV\NAV2013R2\CU29_NO_45254\DVD\NAV.7.1.45254.NO.DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\71\Database\Demo Database NAV (7-1).bak'
$NAVVersion = '2016'
#$CountryCode = 'NO'
$CountryCode = 'W1'
$CUNo = '17'
$DownloadFolder = 'C:\Temp\NAV'
$DVDDestination = "C:\Temp\NAV\NAV$NAVVersion"
$TmpLocation ='C:\Temp\NAV\NAV\Temp'
$ISODir = 'C:\Temp\NAV\NAV\ISO'
#The log file must exists in the folder.
$LogFile = 'C:\Temp\NAV\NAV\Log\Install.log'

$Download = Get-NAVCumulativeUpdateFile -version $NAVVersion -CountryCode $CountryCode -CUNo $CUNo -DownloadFolder $DownloadFolder -ShowDownloadFolder #-GetInfoOnly

$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath $Download.filename
#$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath 'C:\Temp\NAV\NAV2017\NAV.10.0.14199.NO.DVD.zip'
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath 'C:\Temp\NAV\NAV2017\NAV.10.0.14199.NO.DVD.zip' -TmpLocation $TmpLocation -IsoDirectory $ISODir 
$ZippedDVDfile = $Download.filename
$InstallationPath = Unzip-NAVCumulativeUpdateDownload -SourcePath $ZippedDVDfile -DestinationPath $DVDDestination
#$InstallationPath = 'C:\Temp\NAV\NAV2017\CU3\DVD'
$InstallationResult = Install-NAV -DVDFolder $InstallationPath -Configfile $InstallConfig -LicenseFile $License -Log $LogFile
#$InstallationResult = Install-NAV -DVDFolder 'C:\Temp\NAV\NAV2017\CU1\DVD' -Configfile $InstallConfig -LicenseFile $License -Log $LogFile
#MODIFIED (DEV)
#Restore-SQLBackupFile-SID -BackupFile $Backupfile -DatabaseName 'Demo Database NAV (7-1) CU29'
#New-NAVEnvironment -ServerInstance $NewServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License


