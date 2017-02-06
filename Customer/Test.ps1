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

$ExportPath = 'C:\NAVUpgrade\Customer\Incadea\NAV2013R2\CU29\Incadea\FOB\MC\V1\Merged'
$MergedObjectsFile = 'C:\NAVUpgrade\Customer\Incadea\NAV2013R2\CU29\Incadea\FOB\MC\V1\AllMergedObjects.txt'
$ExportPathTest = 'C:\NAVUpgrade\Customer\Incadea\NAV2013R2\CU29\Incadea\FOB\MC\V1\Test'
$NAVSeverInstance = 'de01fin06.incadea.loc:7046/incno_accounts'
$Filter = 'Type=Codeunit|Page,ID=21'
#Export-NAVApplicationObject2 -ServerInstance  $NAVSeverInstance -Path $ExportFile -Filter $Filter
Split-NAVApplicationObjectFile -Source (join-path $ExportPath  'TABles.txt') -Destination $ExportPath
Split-NAVApplicationObjectFile -Source (join-path $ExportPathTest 'TAB.txt') -Destination $ExportPathTest
Join-NAVApplicationObjectFile -Source $ExportPath -Destination $MergedObjectsFile
$file = 'C:\Temp\inc.navdata'
Export-NAVData -DatabaseServer 'DE01FIN06.incadea.loc' -DatabaseName 'incno_accounts' -FileName (join-path $DownloadFolder  (incno_accounts+ '_AllCompanies.navdata')) -CompanyName 'SI-Data A/S' -IncludeApplicationData -IncludeGlobalData -IncludeApplication
Export-NAVData -DatabaseName incno_accounts -FileName $file -CompanyName ('SI-Data A/S') -DatabaseServer 'DE01FIN06.incadea.loc' -IncludeApplication -IncludeApplicationData -IncludeGlobalData
