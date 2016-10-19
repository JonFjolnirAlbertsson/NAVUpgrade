$CompanyName = 'Normark'
$Location = "C:\GitHub\NAVUpgrade\Customer\$CompanyName\Script"
. (join-path $Location ('Set-UpgradeSettings.ps1'))
#$WorkingFolder = 'C:\NAVUpgrade\Customer\Normark\NAV2016\CU5\Upgrade_NAV90CU5Normark'

$ObjectName ='PAG42'
Open-File-SID -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -OpenModified -OpenMerged -OpenTarget 

