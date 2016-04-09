$ObjectName ='TAB39'
Open-File-SID -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged -OpenModified -OpenTarget -WorkingFolder 'C:\NAVUpgrade\Customer\SI-Data\NAV2013R2\CU29\Upgrade_NAV71CU29SIData'

$WindowsUser = 'SI-DATA\JAL'
New-NAVServerUser -ServerInstance $UpgradeName -WindowsAccount $WindowsUser
New-NAVServerUserPermissionSet -ServerInstance $UpgradeName -WindowsAccount $WindowsUser -PermissionSetId 'SUPER' -ErrorAction Continue
