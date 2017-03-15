$Location = 'C:\GitHub\NAVUpgrade\Customer\Incadea\FastFit\Script\'
. (join-path $Location 'Set-UpgradeSettings.ps1')

$ObjectName ='TAB36'
#Open-File-SID -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenTarget -OpenMerged 
Open-File-SID -ObjectName $ObjectName -WorkingFolder $WorkingFolder -OpenInNotepadPlus -UseWaldoFolders
