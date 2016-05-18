#Base Path
$RootFolderPath = "C:\NavUpgrade"
#NAV
$VersionListPrefixes = 'NAVW1', 'NAVNO', 'I'
$NAVLicense = "$RootFolderPath\License\NAV2016.flf"
$CompareObject = '*.TXT'
#Folders and files
$WorkingFolder = join-path $RootFolderPath 'Customer\Sandven'
$TargetFile = join-path $WorkingFolder 'Sandven_NAV2009_COD.txt'
$TargetFile = join-path $WorkingFolder 'Sandven_NAV2009_TAB.txt'
$TargetFile = join-path $WorkingFolder 'Sandven_NAV2009_PAG.txt'
$TargetFile = join-path $WorkingFolder 'Sandven_NAV2009.txt'
$TargetFolder = join-path $WorkingFolder 'Target'
$ModifiedFile = join-path $WorkingFolder 'Compello_NAV2013_R2_CU7_NO.txt'
$ModifiedFolder = join-path $WorkingFolder 'Modified'
$OriginalFile = join-path $WorkingFolder 'NAV2013_R2_CU7_NO.txt'
$OriginalFolder = join-path $WorkingFolder 'Original'
$ResultFolder = join-path $WorkingFolder 'Result'
$ResultFile = join-path $WorkingFolder 'MergeResult.txt'
#Databases and backup folder and files
$BackupfileCaompanyDB = ''

Split-NAVApplicationObjectFile -Source $TargetFile -Destination $TargetFolder
Split-NAVApplicationObjectFile -Source $ModifiedFile -Destination $ModifiedFolder
Split-NAVApplicationObjectFile -Source $OriginalFile -Destination $OriginalFolder

#New-NAVEnvironment -ServerInstance $UpgradeObjectsName  -BackupFile $BackupfileCaompanyDB -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalFile `    -ModifiedObjects $ModifiedFile `
    -TargetObjects $TargetFile `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

Split-NAVApplicationObjectFile -Source $ResultFile -Destination $ResultFolder

Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

Split-NAVApplicationObjectFile -Source 'C:\NAVUpgrade\Customer\SI-Data\NAV2013R2\CU29\Incadea\FOB\Changesv10.txt' -Destination 'C:\NAVUpgrade\Customer\SI-Data\NAV2013R2\CU29\Incadea\FOB\Modified'