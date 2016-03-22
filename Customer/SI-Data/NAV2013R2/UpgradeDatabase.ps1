$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\NAV2013R2"
#. (join-path $PSScriptRoot 'Set-UpgradeSettings.ps1')
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

New-NAVEnvironment -ServerInstance $ModifiedServerInstance -BackupFile $ModifiedDatabaseBackupLocation -ErrorAction Stop -EnablePortSharing -LicenseFile $NAVLicense

[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split

#Clear-Host

UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject

$UpgradeAction = [UpgradeAction]::Merge
UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject -OpenConflictFilesInKdiff $True

$UpgradeAction = [UpgradeAction]::Join
UpgradeNAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects `
                -UpgradeAction $UpgradeAction -CompareObject $CompareObject
                #-CompareObject $CompareObject -RemoveOriginalFilesNotInTarget $True -RemoveModifyFilesNotInTarget $True

RestoreDBFromFile -backupFile $BackupFilePath -dbNewname $dbName

#SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "NT-MYNDIGHET\NETTVERKSTJENESTE"
SetNAVServiceUserPermission -DatabaseServer $DBServer -DBName $dbName -ADUser "SI-Data\SQL"

CreateNAVServerInstance -DBServer $DBServer -DataBase $dbName -FirstPortNumber $FirstPort -NavServiceInstance $NavServiceInstance
CreateNavUser -User si-data\jal -NavServiceInstance $NavServiceInstance 

#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance 
Import-NAVServerLicense $NavServiceInstance  -LicenseData ([Byte[]]$(Get-Content -Path $LicensFile -Encoding Byte))
#Import-NAVServerLicense -LicenseFile $LicensFile -ServerInstance $NavServiceInstance -Database $dbName -Force

Import-NAVApplicationObject $NAVAPPObjects2Import -DatabaseServer $DBServer -DatabaseName $dbName -ImportAction Overwrite -SynchronizeSchemaChanges No -LogPath $ImportLog -Verbose

Compile-NAVApplicationObject -DatabaseServer $DBServer -DatabaseName $dbName -LogPath $ImportLog -Recompile -SynchronizeSchemaChanges No

  
$StoppedDateTime = Get-Date
  
Write-Host ''
Write-Host ''    
Write-Host '****************************************************' -ForegroundColor Yellow
write-host 'Done!' -ForegroundColor Yellow
Write-host "$($UpgradedServerInstance.ServerInstance) created!" -ForegroundColor Yellow
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Yellow
Write-Host '****************************************************' -ForegroundColor Yellow

