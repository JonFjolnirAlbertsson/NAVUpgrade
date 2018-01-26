﻿Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$Location = (Split-Path $psise.CurrentFile.FullPath)
. (join-path $Location 'Set-UpgradeSettings.ps1')
clear-host
$StartedDateTime = Get-Date
#<#
# Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}
#>
# Merge Customer database objects and NAV 2018 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

# Split files, merge, compare and join to one file.
# Define Variablies
$CompareObjectFilter = '*.TXT'
$ResultFolderPath =  join-path $WorkingFolder 'Result'
$TargetFolderPath =  join-path $WorkingFolder 'Target'
$ResultMergedFolderPath =  join-path $ResultFolderPath 'Merged'
$MergedFolderPath =  join-path $WorkingFolder 'Merged'
$ToBeJoinedFolderPath = join-path $MergedFolderPath 'ToBeJoined'
$ResultDestinationFile = join-path $WorkingFolder 'Result_Objects.TXT'
$ToBeJoinedDestinationFile = join-path $WorkingFolder 'ToBeJoined_Objects.TXT'
# Split Original, Modified and Target object files
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObjectFilter -Split
# Merge object file to new file in the Result folder
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObjectFilter -Merge
# Compare MergeResult (Waldo) and Result (Standard NAV) and write result to file
Compare-Folders -WorkingFolderPath $WorkingFolder -CompareObjectFilter $CompareObjectFilter -CopyMergeResult2ToBeJoined -MoveConflictItemsFromToBeJoined2Merged -CompareContent -CompareMergeResult2Result -DropObjectProperty 
# Remove Original standard objects that have been removed or that we do not have license to import to DB as text files
Remove-OriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -WriteResultToFile
# Join Result folder
Join-NAVApplicationObjectFile -Source $ResultMergedFolderPath  -Destination $ResultDestinationFile -Force
# Join ToBeJoined folder
Join-NAVApplicationObjectFile -Source $ToBeJoinedFolderPath  -Destination $ToBeJoinedDestinationFile -Force    
# Compare the $ToBeJoinedDestinationFile file to the $TargetObjects in the "NAV Object Compare" application from Rune Sigurdsen
$NAVObjectCompareWinClient = join-path 'C:\Users\DevJAL\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\NAVObjectCompareWinClient' 'NAVObjectCompareWinClient.appref-ms'
& $NAVObjectCompareWinClient 
# Count number of items in folder
$CompareObjectFilter = 'COD*.TXT'
Write-Host 'Comparing number of items' -ForegroundColor Green
Write-Host "Number of $CompareObjectFilter in $ToBeJoinedFolderPath" + (Get-ChildItem $ToBeJoinedFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
Write-Host "Number of $CompareObjectFilter in $TargetFolderPath" + (Get-ChildItem $TargetFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
$CompareObjectFilter = 'TAB*.TXT'
Write-Host "Number of $CompareObjectFilter in $ToBeJoinedFolderPath" + (Get-ChildItem $ToBeJoinedFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
Write-Host "Number of $CompareObjectFilter in $TargetFolderPath" + (Get-ChildItem $TargetFolderPath -filter $CompareObjectFilter).Count -ForegroundColor Green
# Remember to manually compare the Merged objects with original, modified and target objects, before running this script.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

#Step 1
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step1.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow
#Step 2
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step2.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
$StoppedDateTime = Get-Date
#Step 3
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step3.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
$StoppedDateTime = Get-Date
# Sync and correct errors in NAV 2015
# Remember to load NAV 2015 modules
Sync-NAVTenant -ServerInstance $Nav2015ServiceInstance  -Mode Sync
#Step 4
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step4.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
$StoppedDateTime = Get-Date 
# Start Data upgrade NAV 2015
Start-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -FunctionExecutionMode Serial

# Follow up the data upgrade process
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -Progress
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -Detailed | ogv
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -Detailed | Out-File 'F:\Customer\PP\NAV2015UpgradeLog.txt'
Get-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance -ErrorOnly | ogv

Resume-NAVDataUpgrade -ServerInstance $Nav2015ServiceInstance


#Step 5
$StartedDateTime = Get-Date
$BackupFileName = $UpgradeDataBaseName + "_Step5.bak"
$BackupFilePath = join-path $BackupPath $BackupFileName 
Backup-SqlDatabase -ServerInstance $DBServer -Database $UpgradeDataBaseName -BackupAction Database -BackupFile $BackupFilePath -CompressionOption Default
$StoppedDateTime = Get-Date
Write-Host 'Start at: ' + $StartedDateTime + ' . Finished at: ' + $StoppedDateTime + ' . Total time' + ($StoppedDateTime-$StartedDateTime) -ForegroundColor Yellow 
$StoppedDateTime = Get-Date 

Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow
