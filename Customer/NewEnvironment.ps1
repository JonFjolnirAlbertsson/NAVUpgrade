﻿$DefaultServerInstance = 'DynamicsNAV100'
$NewServerInstance = 'NAV100CU3_Overaasen'
$License = 'C:\NAVUpgrade\License\NAV2017.flf'
#Change the name of the Demo DB to reference the CU number
$InstallConfig = 'C:\GitHub\NAVUpgrade\NAVSetup\FullInstallNAV2017.xml'


#$Backupfile = $CopyFromServerInstance | Backup-NAVDatabase -ErrorAction Stop
#$CopyFromServerInstance | Enable-NAVServerInstancePortSharing
$Backupfile = 'C:\Temp\NAV\NAV2013R2\CU29_NO_45254\DVD\NAV.7.1.45254.NO.DVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\71\Database\Demo Database NAV (7-1).bak'
$NAVVersion = '2017'
$CountryCode = 'NO'
$DownloadFolder = 'C:\Temp\NAV'
$DVDDestination = "C:\Temp\NAV\NAV$NAVVersion"
$TmpLocation ='C:\Temp\NAV\NAV\Temp'
$ISODir = 'C:\Temp\NAV\NAV\ISO'
#The log file must exists in the folder.
$LogFile = 'C:\Temp\NAV\NAV\Log\Install.log'

$CopyFromServerInstance = Get-NAVServerInstance $DefaultServerInstance -ErrorAction Stop
$Download = Get-NAVCumulativeUpdateFile -versions $NAVVersion  -CountryCode $CountryCode -DownloadFolder $DownloadFolder

$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath $Download.filename
#$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath 'C:\Temp\NAV\NAV2017\NAV.10.0.14199.NO.DVD.zip'
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath 'C:\Temp\NAV\NAV2017\NAV.10.0.14199.NO.DVD.zip' -TmpLocation $TmpLocation -IsoDirectory $ISODir 
$InstallationPath = Unzip-NAVCumulativeUpdateDownload -SourcePath $ZippedDVDfile -DestinationPath $DVDDestination

$InstallationResult = Install-NAV -DVDFolder $InstallationPath -Configfile $InstallConfig -LicenseFile $License -Log $LogFile
#$InstallationResult = Install-NAV -DVDFolder 'C:\Temp\NAV\NAV2017\CU1\DVD' -Configfile $InstallConfig -LicenseFile $License -Log $LogFile
#MODIFIED (DEV)
#Restore-SQLBackupFile-SID -BackupFile $Backupfile -DatabaseName 'Demo Database NAV (7-1) CU29'
#$CopyFromServerInstance = Get-NAVServerInstance $DefaultServerInstance -ErrorAction Stop
#New-NAVEnvironment -ServerInstance $NewServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License
#$Backupfile = Backup-NAVDatabase -ServerInstance $DefaultServerInstance  -ErrorAction Stop
$Backupfile = 'E:\Backup\Navision Demo\Demo Database NAV (10-0) CU3.bak'
New-NAVEnvironment -Databasename $NewServerInstance -ServerInstance $NewServerInstance -BackupFile $Backupfile -DatabaseServer localhost -EnablePortSharing -LicenseFile $License 
#New-NAVEnvironment -ServerInstance $NewServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License
