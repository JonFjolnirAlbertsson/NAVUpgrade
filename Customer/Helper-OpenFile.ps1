$CompanyName = 'ELAS'
$Location = "C:\GitHub\NAVUpgrade\Customer\$CompanyName\Script"
. (join-path $Location ('NAV2017-Settings.ps1'))
#$WorkingFolder = 'C:\NAVUpgrade\Customer\Normark\NAV2016\CU5\Upgrade_NAV90CU5Normark'

$ObjectName ='COD80'
Open-File-SID -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenOriginal -UseWaldoFolders

