$WorkingFolder = 'C:\NAVUpgrade\Customer\Incadea\NAV2013R2\CU29\Incadea\FOB\MC\16.01.2017\MC_V7_3 - manual sales inv period calc'
$OriginalObjects = '20170105_CAS-10390-M0Z0.txt'
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

