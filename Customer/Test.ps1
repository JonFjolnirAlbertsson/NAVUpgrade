$NAVVersion = '2017'
$CountryCode = 'NO'
$DownloadFolder = 'C:\Temp\NAV'
$DVDDestination = "C:\Temp\NAV\NAV$NAVVersion"
$TmpLocation ='C:\Temp\NAV\NAV\Temp'
$ISODir = 'C:\Temp\NAV\NAV\ISO'
#The log file must exists in the folder.
$LogFile = 'C:\Temp\NAV\NAV\Log\Install.log'
$InstallConfig = 'C:\GitHub\NAVUpgrade\NAVSetup\FullInstallNAV2017.xml'
$InstallationResult = Install-NAV -DVDFolder 'C:\Temp\NAV\NAV2017\CU1\DVD' -Configfile $InstallConfig -LicenseFile $License -Log $LogFile