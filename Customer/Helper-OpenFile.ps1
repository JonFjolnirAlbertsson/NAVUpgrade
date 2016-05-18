$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')
$ObjectName ='TAB5062'
Open-File-SID -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenMerged -OpenTarget -OpenToBeJoined -WorkingFolder $WorkingFolder

