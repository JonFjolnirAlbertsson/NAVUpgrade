# Client script to start remote session on application server
Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$Location = (Split-Path $psise.CurrentFile.FullPath)
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettings.ps1')
. $scriptLocationPath
# Client Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role Client -DelegateComputer $NAVServerRSName  -Force
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName $NAVServerRSName -UseSSL -Credential $UserCredential –Authentication CredSSP

# Server Site script
clear-host
$StartedDateTime = Get-Date
Set-Location 'C:\'
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\PP\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettings.ps1'
. $scriptLocationPath
## Server Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role server -Force
# Creating Credential for the NAV Server Instance user
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$InstanceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $InstanceUserName, $InstanceSecurePassword 
Import-Module SQLPS -DisableNameChecking 
Import-module (Join-Path "$GitPath\Cloud.Ready.Software.PowerShell\PSModules" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-module (Join-Path "$GitPath\IncadeaNorway" 'LoadModules.ps1') -Force -WarningAction SilentlyContinue | Out-Null
Import-NAVModules-INC -ShortVersion '110' -ImportRTCModule 
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
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
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

