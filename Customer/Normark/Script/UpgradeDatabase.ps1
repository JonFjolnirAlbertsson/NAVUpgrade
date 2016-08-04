$Location = "C:\GitHub\NAVUpgrade\Customer\Normark\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')

clear-host

$StartedDateTime = Get-Date

# Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}

# Create new NAV 2016 company database, to migrate Objects
#New-NAVEnvironment -ServerInstance $UpgradeObjectsName  -BackupFile $TargetDBLocation -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
#Restore-SQLBackupFile-SID -BackupFile $TargetDBLocation -DatabaseName $UpgradeObjectsName

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

#Copy-item "$WorkingFolder\MergeResult\ConflictOriginal" -Destination "$WorkingFolder\Original" -Recurse
#Copy-item "$WorkingFolder\MergeResult\ConflictModified" -Destination "$WorkingFolder\Modified" -Recurse
#Copy-item "$WorkingFolder\MergeResult\ConflictTarget" -Destination "$WorkingFolder\Target" -Recurse
Copy-item "$WorkingFolder\MergeResult\*TXT" -Destination "$WorkingFolder\Merged\ToBeJoined" 
Split-NAVApplicationObjectFile -Source $OriginalObjects -Destination "$WorkingFolder\Original"
Split-NAVApplicationObjectFile -Source $ModifiedObjects -Destination "$WorkingFolder\Modified"
Split-NAVApplicationObjectFile -Source $TargetObjects -Destination "$WorkingFolder\Target"

#NAV2016
#Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join


<#
RemoveOriginalFilesNotInTarget -WorkingFolderPath $WorkingFolder -OriginalFolder $OriginalFolder -TargetFolder $TargetFolder
RemoveModifiedFilesNotInTarget -WorkingFolderPath $WorkingFolder -ModifiedFolder $ModifiedFolder -TargetFolder $TargetFolder
Join-NAVApplicationObjectFile -Destination $DestinationFile -Source $JoinFolder -Force
#>

#Import-NAVApplicationObject $DestinationFile -DatabaseServer $DBServer -DatabaseName $UpgradeName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose
#Import-NAVApplicationObject2 -Path $DestinationFile -ServerInstance $ModifiedServerInstance -ImportAction Default -LogPath $WorkingFolder -NavServerName $NAVServer -SynchronizeSchemaChanges Yes

#Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $UpgradeName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

  
$StoppedDateTime = Get-Date
  
Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

