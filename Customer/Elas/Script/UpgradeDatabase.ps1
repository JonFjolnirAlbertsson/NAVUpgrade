$Location = "C:\GitHub\NAVUpgrade\Customer\Elas\Script"
. (join-path $Location 'Set-UpgradeSettings.ps1')

clear-host

$StartedDateTime = Get-Date

#Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}

#Restore company database, to be upgraded.
#New-NAVEnvironment -ServerInstance $UpgradeObjectsName  -BackupFile $BackupfileCaompanyDB -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense
Restore-SQLBackupFile-SID -BackupFile $BackupfileCaompanyDB -DatabaseName $UpgradeName

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $ModifiedObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

#Reset Workingfolder
if (test-path $WorkingFolderNAV2009){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolderNAV2009 ?"){
        Remove-Item -Path $WorkingFolderNAV2009 -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}
# Split object files and create folders for NAV 2009.
[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split
$CompareObject = 'TAB*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetNAV2009Objects -UpgradeAction $UpgradeAction -CompareObject $CompareObject
# Merge Customer database table objects and NAV 20009 table objects.
$UpgradeAction = [UpgradeAction]::Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetNAV2009Objects -UpgradeAction $UpgradeAction -CompareObject $CompareObject


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

