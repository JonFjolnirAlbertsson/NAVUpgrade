$Location = "C:\GitHub\NAVUpgrade\Customer\Elas\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')
$ObjectName ='FOR4'
Open-File-SID -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenTarget -WorkingFolder $WorkingFolder

