$CompanyName = 'Øveraasen'
#$CompanyName = 'NOBI'
#$CompanyName = 'Incadea\FastFit'
$Location = "C:\GitHub\NAVUpgrade\Customer\$CompanyName\Script"
. (join-path $Location ('Set-UpgradeSettings.ps1'))
#. (join-path $Location ('NAV2017-Settings.ps1'))
#Open Files with conflict. Using the Merge Folder to merge the conflict
#$ObjectName ='COD430'
$ObjectName ='TAB5407'
Open-File-SID -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenTarget -OpenMerged -OpenToBeJoined

#Open Files with no conflict from MergedResult or the Result folder 
3#$ObjectName ='COD5906'
#Open-File-SID -ObjectName $ObjectName -WorkingFolder $WorkingFolder -OpenInNotepadPlus -UseWaldoFolders
