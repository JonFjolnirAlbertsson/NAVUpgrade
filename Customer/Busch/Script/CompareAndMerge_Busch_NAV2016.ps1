# Import settings
. (Join-Path $PSScriptRoot 'Set-NAVEnvironmentSettings.ps1') -ErrorAction Stop


if (-not (Test-Path $ISODir)) {New-Item -Path $ISODir -ItemType directory | Out-null}
if (-not (Test-Path $TmpLocation)) {New-Item -Path $TmpLocation -ItemType directory | Out-null}
if (-not (Test-Path $InstallLog)) {New-Item -Path $InstallLog -ItemType directory | Out-null}

#Looks like it must run in IE not Edge
$Download = Get-NAVCumulativeUpdateFile -CountryCodes NO -versions $NAVVersion -DownloadFolder $TmpLocation

break
#We only need to run this if we want ISO file
#$NAVISOFile = New-NAVCumulativeUpdateISOFile -CumulativeUpdateFullPath $Download.filename -TmpLocation $TmpLocation -IsoDirectory $ISODir 

#$ZippedDVDfile  = 'C:\NAV Setup\NAV2016\Temp\489822_NOR_i386_zip.exe'
$ZippedDVDfile  = $Download.filename

#Get-ChildItem -path (Join-Path $PSScriptRoot '..\PSFunctions\*.ps1') | foreach { . $_.FullName}

$VersionInfo = Get-NAVCumulativeUpdateDownloadVersionInfo -SourcePath $ZippedDVDfile
$DVDDestination = "$NAVRootFolder\" + $VersionInfo.Product + $NAVVersion + $VersionInfo.Country +$Download.CUNo  + '_' + $VersionInfo.Build + "\DVD\"

if (-not (Test-Path $DVDDestination)) {New-Item -Path $DVDDestination -ItemType directory | Out-null}

$InstallationPath = Unzip-NAVCumulativeUpdateDownload -SourcePath $ZippedDVDfile -DestinationPath $DVDDestination

$InstallationResult = Install-NAV -DVDFolder $InstallationPath -Configfile $NAVInstallConfigFile -Log $InstallLog

break

Import-NAVServerLicense -ServerInstance $InstallationResult.ServerInstance -LicenseFile $Licensefile

Break
$WorkingFolder  = '$NAVRootFolder\WorkingFolder'
Export-NAVApplicationObject `
    -DatabaseServer ([Net.DNS]::GetHostName()) `
    -DatabaseName $Databasename `
    -Path (join-path $WorkingFolder ($VersionInfo.Build + '.txt')) `
    -LogPath (join-path $WorkingFolder 'Export\Log') `
    -ExportTxtSkipUnlicensed `
    -Force    


break

#$UnInstallPath =$InstallationPath
#$UnInstallPath = "C:\NAV Setup\NAV2016\NAV2016_NO_CU1\DVD\"
#UnInstall-NAV -DVDFolder $UnInstallPath -Log $UnInstallLog

New-NAVEnvironment -ServerInstance $OriginalServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License

[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split

#Clear-Host

UpgradeNAVCode -RootFolderPath $RootFolderPath  -CompanyFolderName $CompanyFolderName -Version $Version `
                -CompanyOriginalFileName $CompanyOriginalFileName -CompanyModifiedFileName $CompanyModifiedFileName `
                -CompanyTargetFileName $CompanyTargetFileName -UpgradeAction $UpgradeAction -CompareObject $CompareObject

$UpgradeAction = [UpgradeAction]::Merge
UpgradeNAVCode -RootFolderPath $RootFolderPath  -CompanyFolderName $CompanyFolderName -Version $Version `
                -CompanyOriginalFileName $CompanyOriginalFileName -CompanyModifiedFileName $CompanyModifiedFileName `
                -CompanyTargetFileName $CompanyTargetFileName -UpgradeAction $UpgradeAction `
                #-CompareObject $CompareObject
                -CompareObject $CompareObject -OpenConflictFilesInKdiff $False

$UpgradeAction = [UpgradeAction]::Join
UpgradeNAVCode -RootFolderPath $RootFolderPath  -CompanyFolderName $CompanyFolderName -Version $Version `
                -CompanyOriginalFileName $CompanyOriginalFileName -CompanyModifiedFileName $CompanyModifiedFileName `
                -CompanyTargetFileName $CompanyTargetFileName -UpgradeAction $UpgradeAction `
                -CompareObject $CompareObject -RemoveOriginalFilesNotInTarget $True -RemoveModifyFilesNotInTarget $True
                #-CompareObject $CompareObject


RestoreDBFromFile -backupFile $BackupFilePath -dbNewname $dbName

#SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "NT-MYNDIGHET\NETTVERKSTJENESTE"
SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "SI-Data\SQL"

CreateNAVServerInstance -DBServer $DBServer -DataBase $dbName -FirstPortNumber $FirstPort -NavServiceInstance $NavServiceInstance
CreateNavUser -User si-data\jal -NavServiceInstance $NavServiceInstance 

#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance 
Import-NAVServerLicense $NavServiceInstance  -LicenseData ([Byte[]]$(Get-Content -Path $LicensFile -Encoding Byte))
#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance -Database $dbName -Force

Import-NAVApplicationObject $NAVAPPObjects2Import -DatabaseServer $DBServer -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose

Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No


