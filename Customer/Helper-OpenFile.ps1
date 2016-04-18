$Location = "C:\GitHub\NAVUpgrade\Customer\Elas\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')
$ObjectName ='TAB27'
Open-File-SID -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenMerged -OpenTarget -OpenToBeJoined -WorkingFolder $WorkingFolder

