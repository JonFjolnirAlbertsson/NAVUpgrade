# Import settings
$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\NAV2013R2"
#. (Join-Path $PSScriptRoot 'Set-NAVEnvironmentSettings.ps1') -ErrorAction Stop
. (Join-Path $Location 'Set-NAVEnvironmentSettings.ps1') -ErrorAction Stop



if (-not (Test-Path $ISODir)) {New-Item -Path $ISODir -ItemType directory | Out-null}
if (-not (Test-Path $TmpLocation)) {New-Item -Path $TmpLocation -ItemType directory | Out-null}
if (-not (Test-Path $InstallLog)) {New-Item -Path $InstallLog -ItemType directory | Out-null}

#Looks like it must run in IE not Edge
$Download = Get-NAVCumulativeUpdateFile -CountryCodes NO -versions $NAVVersion -DownloadFolder $TmpLocation

break
#We only need to run this if we want ISO file
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 

#NAV2013R2CU29NO
$ZippedDVDfile  = 'C:\Temp\NAV\NAV2013R2\490430_NOR_i386_zip.exe'
#$ZippedDVDfile  = $Download.filename


$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath $ZippedDVDfile
$DVDDestination = "$NAVRootFolder\" + $VersionInfo.Product + $NAVVersion + $VersionInfo.Country +$Download.CUNo  + '_' + $VersionInfo.Build + "\DVD\"

if (-not (Test-Path $DVDDestination)) {New-Item -Path $DVDDestination -ItemType directory | Out-null}

$InstallationPath = Unzip-NAVCumulativeUpdateDownload -SourcePath $ZippedDVDfile -DestinationPath $DVDDestination

if (-not (Test-Path $InstallLogFolder)) {New-Item -Path $InstallLogFolder -ItemType directory | Out-null}

$InstallationResult = Install-NAV -DVDFolder $InstallationPath -Configfile $NAVInstallConfigFile -Log $InstallLog

break


#New-NAVEnvironment -ServerInstance $OriginalServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License
#Import-NAVServerLicense -ServerInstance $InstallationResult.ServerInstance -LicenseFile $Licensefile
Set-NAVServerInstance -ServerInstance $NavServiceInstance -Restart
Import-NAVServerLicense -ServerInstance $NavServiceInstance -LicenseFile $LicensFile
Set-NAVServerInstance -ServerInstance $NavServiceInstance -Restart

Break
#Export target objects from Demo DB
Export-NAVApplicationObject2 `
    -DatabaseServer ([Net.DNS]::GetHostName()) `
    -DatabaseName $dbName `
    -Path (join-path $WorkingFolder ($VersionInfo.Build + '.txt')) `
    -LogPath (join-path $WorkingFolder 'Export\Log') `
    -ExportTxtSkipUnlicensed `
    -Force    

#Export-NAVApplicationObject2 -Path (join-path $WorkingFolder ($VersionInfo.Build + '.txt')) -ServerInstance $NavServiceInstance -LogPath (join-path $WorkingFolder 'Export\Log')

break

#$UnInstallPath =$InstallationPath
#$UnInstallPath = "C:\NAV Setup\NAV2016\NAV2016_NO_CU1\DVD\"
#UnInstall-NAV -DVDFolder $UnInstallPath -Log $UnInstallLog


