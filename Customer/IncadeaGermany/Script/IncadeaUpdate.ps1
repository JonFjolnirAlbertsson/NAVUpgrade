$CompanyName = 'IncadeaGermany'
$Location = "C:\GitHub\NAVUpgrade\Customer\$CompanyName\Script"
. (join-path $Location 'Set-IncadeaUpdateSettings.ps1')


clear-host

$StartedDateTime = Get-Date

#Reset Workingfolder
if (test-path $WorkingFolder)
{
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}

Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -Split
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolder -Join 
# Merge Customer database objects and NAV 2016 objects.
#$MergeResult = Merge-NAV2013R2UpgradeObjects -OriginalObjects $OriginalObjects -ModifiedObjects $ModifiedObjects -TargetObjects $TargetObjects -WorkingFolder $WorkingFolder -VersionListPrefixes $VersionListPrefixes -Force

