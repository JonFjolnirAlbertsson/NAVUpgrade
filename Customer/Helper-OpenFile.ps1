Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
#$CompanyName = 'PP'
$CompanyName = 'Incadea\FastFit'
$Location = join-path (Split-Path $psise.CurrentFile.FullPath) "$CompanyName\Script"
. (join-path $Location ('Set-UpgradeSettings.ps1'))
#Open Files with conflict. Using the Merge Folder to merge the conflict
#$ObjectName ='COD430'
#<#
$ObjectName ='COD1'
Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged -OpenTarget -OpenModified -OpenOriginal -OpenToBeJoined
Open-File-INC -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenModified -OpenOriginal -OpenTarget -UseWaldoFolders -OpenInNotepadPlus

#>

