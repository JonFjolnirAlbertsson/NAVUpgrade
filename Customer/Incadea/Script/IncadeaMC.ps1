$WorkingFolder = 'C:\NAVUpgrade\Customer\Incadea\NAV2013R2\CU29\Incadea\FOB\MC\Original'
$OriginalObjects = 'Tables.txt'
$OriginalObjects = join-path $WorkingFolder $OriginalObjects
Merge-NAVCode -WorkingFolderPath $WorkingFolder -ModifiedFileName $OriginalObjects -Split
$OriginalObjects = 'CodeUnits.txt'
$OriginalObjects = join-path $WorkingFolder $OriginalObjects
Merge-NAVCode -WorkingFolderPath $WorkingFolder -ModifiedFileName $OriginalObjects -Split
$OriginalObjects = 'Pages.txt'
$OriginalObjects = join-path $WorkingFolder $OriginalObjects
Merge-NAVCode -WorkingFolderPath $WorkingFolder -ModifiedFileName $OriginalObjects -Split
#Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolder -Join 
# Merge Customer database objects and NAV 2016 objects.
#$MergeResult = Merge-NAV2013R2UpgradeObjects -OriginalObjects $OriginalObjects -ModifiedObjects $ModifiedObjects -TargetObjects $TargetObjects -WorkingFolder $WorkingFolder -VersionListPrefixes $VersionListPrefixes -Force

