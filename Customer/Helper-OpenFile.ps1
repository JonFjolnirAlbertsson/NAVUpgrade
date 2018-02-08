﻿Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$CompanyName = 'Overaasen'
#$CompanyName = 'Incadea\FastFit'
$Location = join-path (Split-Path $psise.CurrentFile.FullPath) "$CompanyName\Script"
. (join-path $Location ('Set-UpgradeSettings.ps1'))
#Open Files with conflict. Using the Merge Folder to merge the conflict
#$ObjectName ='COD430'
#<
$ObjectName ='TAB72330'
#Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged 
#Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged -OpenTarget -OpenModified -OpenOriginal -OpenToBeJoined
Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInBCompare -OpenModified -OpenOriginal -UseWaldoFolders 
Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInBCompare -OpenTarget -OpenMerged 
#>

