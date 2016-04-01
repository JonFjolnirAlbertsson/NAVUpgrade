# Import settings
$Location = "C:\GitHub\NAVUpgrade\Customer\Elas\Script"
. (Join-Path $Location 'Set-UpgradeSettings.ps1') -ErrorAction Stop



if (-not (Test-Path $ISODir)) {New-Item -Path $ISODir -ItemType directory | Out-null}
if (-not (Test-Path $TmpLocation)) {New-Item -Path $TmpLocation -ItemType directory | Out-null}
if (-not (Test-Path $InstallLog)) {New-Item -Path $InstallLog -ItemType directory | Out-null}

#Looks like it must run in IE not Edge
$Download = Get-NAVCumulativeUpdateFile -CountryCodes NO -versions $NAVVersion -DownloadFolder $TmpLocation

break
#We only need to run this if we want ISO file
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 

#NAV2013R2CU29NO
#$ZippedDVDfile  = 'C:\Temp\NAV\NAV2013R2\490430_NOR_i386_zip.exe'
$ZippedDVDfile  = $Download.filename


$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath $ZippedDVDfile
$DVDDestination = "$NAVRootFolder\" + $VersionInfo.Product + $NAVVersion + $VersionInfo.Country +$Download.CUNo  + '_' + $VersionInfo.Build + "\DVD\"

if (-not (Test-Path $DVDDestination)) {New-Item -Path $DVDDestination -ItemType directory | Out-null}

$InstallationPath = Unzip-NAVCumulativeUpdateDownload -SourcePath $ZippedDVDfile -DestinationPath $DVDDestination

if (-not (Test-Path $InstallLogFolder)) {New-Item -Path $InstallLogFolder -ItemType directory | Out-null}

$InstallationResult = Install-NAV -DVDFolder $InstallationPath -Configfile $NAVInstallConfigFile -Log $InstallLog

break

#Create NAV 2016 demo database and service, used to create target migrate objects.
New-NAVEnvironment-SID -ServerInstance $UpgradeObjectsName -BackupFile $BackupfileTargetDB -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
#Remove-NAVEnvironment -ServerInstance $UpgradeObjectsName
#Import-NAVServerLicense -ServerInstance $InstallationResult.ServerInstance -LicenseFile $Licensefile
#Import-NAVServerLicense -ServerInstance $UpgradeObjectsName -LicenseFile $NAVLicense
#Set-NAVServerInstance -ServerInstance $UpgradeObjectsName -Restart

Break
#Export target objects from Demo DB
Export-NAVApplicationObject `
    -DatabaseServer ([Net.DNS]::GetHostName()) `
    -DatabaseName $UpgradeName `
    -Path (join-path $ObjectLibrary ($VersionInfo.Product + $NAVVersion + '_' + $NAVCU + '_' + $VersionInfo.Country + '.txt')) `
    -LogPath (join-path $WorkingFolder 'Export\Log') `
    -ExportTxtSkipUnlicensed `
    -Force    

#Export-NAVApplicationObject2 -Path (join-path $WorkingFolder ($VersionInfo.Build + '.txt')) -ServerInstance $NavServiceInstance -LogPath (join-path $WorkingFolder 'Export\Log')

break
#Create NAV 2015 Company database and service, used to create target migrate objects.
#Remember to Load NAV 2015 Module first
New-NAVEnvironment-SID -ServerInstance $NAV2015DBName -BackupFile $NAV2015BackupFile -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
#Remove-NAVEnvironment -ServerInstance $NAV2015DBName
Break
#Export objects from Demo DB
Export-NAVApplicationObject `
    -DatabaseName $NAV2015DBName `
    -Path (join-path $ObjectLibrary ($VersionInfo.Product + '2015_' + $NAV2015CU + '_' + $VersionInfo.Country + '.txt')) `
    -LogPath (join-path $WorkingFolder 'Export\Log') `
    -ExportTxtSkipUnlicensed `
    -Force    
break

#Create NAV 2009 database, used to create migrate tables.
Restore-SQLBackupFile-SID -BackupFile $NAV2009BackupFile -DatabaseName $NAV2009DBName
break

#$UnInstallPath =$InstallationPath
#$UnInstallPath = "C:\NAV Setup\NAV2016\NAV2016_NO_CU1\DVD\"
#UnInstall-NAV -DVDFolder $UnInstallPath -Log $UnInstallLog


