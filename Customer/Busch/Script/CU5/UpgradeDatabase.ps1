$Location = "C:\GitHub\NAVUpgrade\Customer\Busch\Script\CU5"
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

# Restore company database, to be upgraded.
# New-NAVEnvironment -ServerInstance $UpgradeObjectsName  -BackupFile $BackupfileCaompanyDB -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
Restore-SQLBackupFile-SID -BackupFile $BackupfileCaompanyDB -DatabaseName $UpgradeName

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

# Split object files and create folders.
$CompareObject = '*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
# Merge Customer database table objects and NAV 20009 table objects.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects  -CompareObject $CompareObject -Merge
# Use Merge-Helper to merge NAV conflict objects

# Join Merged objects to one text file.
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

<#
[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split

#Clear-Host

UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject

$UpgradeAction = [UpgradeAction]::Merge
UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject -OpenConflictFilesInKdiff $True

#$UpgradeAction = [UpgradeAction]::Join
#UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
#                -UpgradeAction $UpgradeAction -CompareObject $CompareObject `
#                -CompareObject $CompareObject -RemoveOriginalFilesNotInTarget $True -RemoveModifyFilesNotInTarget $True

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

