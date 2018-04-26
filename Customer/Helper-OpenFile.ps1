Set-Location -Path (Split-Path $psise.CurrentFile.FullPath)
$CompanyName = 'PP'
$CompanyName = 'Heydi'
#$CompanyName = 'Incadea\FastFit'
$Location = join-path (Split-Path $psise.CurrentFile.FullPath) "$CompanyName\Script"
. (join-path $Location ('Set-UpgradeSettings.ps1'))
#Open Files with conflict. Using the Merge Folder to merge the conflict
#$ObjectName ='COD430'
#<
$ObjectName ='TAB6'
#Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged 
#Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged -OpenTarget -OpenModified -OpenOriginal -OpenToBeJoined
Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInBCompare -OpenModified -OpenOriginal #-UseWaldoFolders 
Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInBCompare -OpenTarget -OpenMerged 
#Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInBCompare -OpenMerged -OpenToBeJoined
#>
#Split-NAVApplicationObjectFile -Source "C:\incadea\Customer\PP\NAV2018\CU03\Upgrade_PP\Merged\CU02\TAB_Modified_15-383.txt" -Destination 'C:\incadea\Customer\PP\NAV2018\CU03\Upgrade_PP\Merged\CU02' 
