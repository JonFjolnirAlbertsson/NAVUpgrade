$WorkingFolder = 'C:\NAVUpgrade\Customer\Incadea\NAV2013R2\CU29\Incadea\FOB\Update15-16\Merge'
$ModifiedObjects = 'TAB17 and 98 and 50003.txt'
$ModifiedObjects = join-path $WorkingFolder $ModifiedObjects
Merge-NAVCode -WorkingFolderPath $WorkingFolder -ModifiedFileName $ModifiedObjects -Split
$ModifiedObjects = 'COD 12 and 40 and 50000.txt'
$ModifiedObjects = join-path $WorkingFolder $ModifiedObjects
Merge-NAVCode -WorkingFolderPath $WorkingFolder -ModifiedFileName $ModifiedObjects -Split
#Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolder -Join 
# Merge Customer database objects and NAV 2016 objects.
#$MergeResult = Merge-NAV2013R2UpgradeObjects -OriginalObjects $OriginalObjects -ModifiedObjects $ModifiedObjects -TargetObjects $TargetObjects -WorkingFolder $WorkingFolder -VersionListPrefixes $VersionListPrefixes -Force

