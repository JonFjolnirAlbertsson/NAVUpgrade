Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
#$Location = 
$CompanyName = 'PP'
#$CompanyName = 'Incadea\FastFit'
$Location = join-path (Split-Path $psise.CurrentFile.FullPath) "$CompanyName\Script"
. (join-path $Location ('Set-UpgradeSettings.ps1'))
#$WorkingFolder = "C:\incadea\Customer\$CompanyName \NAV2018\CU01"
#$WorkingFolder = join-path 'C:\Git\NAV AddOns' 'EHF\PDF'

#. (join-path $Location ('NAV2017-Settings.ps1'))
#Open Files with conflict. Using the Merge Folder to merge the conflict
#$ObjectName ='COD430'
#<#
$ObjectName ='TAB81'
Open-File-SID -WorkingFolder $WorkingFolder -ObjectName $ObjectName -OpenInNotepadPlus -OpenMerged #-OpenTarget -OpenMerged -OpenToBeJoined
Open-File-SID -ObjectName $ObjectName -WorkingFolder $WorkingFolder -OpenInNotepadPlus -UseWaldoFolders
#>

#Remove-OriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -WriteResultToFile
#Open Files with no conflict from MergedResult or the Result folder 
#$ObjectName ='COD5906'
#Open-File-SID -ObjectName $ObjectName -WorkingFolder $WorkingFolder -OpenInNotepadPlus -UseWaldoFolders
#Split-NAVApplicationObjectFile -Source 'C:\Git\NAV AddOns\ICA\All New and Changed objects.txt' -Destination 'C:\Git\NAV AddOns\ICA\Modified'
