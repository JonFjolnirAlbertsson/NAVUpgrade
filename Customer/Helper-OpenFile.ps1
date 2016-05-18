$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')
<<<<<<< HEAD
$ObjectName ='TAB5062'
Open-File-SID -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenMerged -OpenTarget -OpenToBeJoined -WorkingFolder $WorkingFolder
=======
$ObjectName ='FOR4'
Open-File-SID -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenTarget -WorkingFolder $WorkingFolder
>>>>>>> origin/master

