$Location = 'C:\GitHub\NAVUpgrade\Customer\Incadea\FastFit\Script\'
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
Restore-SQLBackupFile-SID -BackupFile $BackupfileNAVDemoDB -DatabaseName $DemoDBName 
Restore-SQLBackupFile-SID -BackupFile $BackupfileAppDB -DatabaseName $AppDBName 
Restore-SQLBackupFile-SID -BackupFile $BackupfileDEALER1DB -DatabaseName $DEALER1DBName 
Restore-SQLBackupFile-SID -BackupFile $BackupfileNAVTargetDemoDB -DatabaseName $TargetDemoDBName
#Remove-SQLDatabase -DatabaseName $DEALER1DBName
Write-host "Create Service Instance"
New-NAVEnvironment  -EnablePortSharing -ServerInstance $AppDBName 
# Set instance to Multitenant
$CurrentServerInstance = Get-NAVServerInstance -ServerInstance $AppDBName
Write-host "Prepare NST for MultiTenancy"
$CurrentServerInstance | Set-NAVServerInstance -stop
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName MultiTenant -KeyValue "true"
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseServer -KeyValue ""
$CurrentServerInstance | Set-NAVServerConfiguration -KeyName DatabaseName -KeyValue ""
$CurrentServerInstance | Set-NAVServerInstance -start
 
Write-host "Mount app"
$CurrentServerInstance | Mount-NAVApplication -DatabaseServer $DBServer -DatabaseName $AppDBName 
 
Write-host "Mount Tenants"
#Mount-NAVTenant -ServerInstance DynamicsNAV71 -Id $MainTenant -DatabaseName $Databasename -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase
Mount-NAVTenant -ServerInstance $AppDBName -DatabaseName $DEALER1DBName -Id $Dealer1Tenant  -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase

Sync-NAVTenant -ServerInstance $AppDBName -Tenant $Dealer1Tenant
#Remove-NAVServerUser -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
#Remove-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant
New-NAVServerUser -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant -LicenseType Full -State Enabled
New-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $AppDBName -WindowsAccount $UserName -Tenant $Dealer1Tenant 
Get-NAVServerUser -ServerInstance $AppDBName -Tenant $Dealer1Tenant
#Export all objects from Demo DB to text file.
#Export-NAVApplicationObject2 -Path $TargetObjects -ServerInstance $NavServiceInstance -LogPath $LogPath

# Merge Customer database objects and NAV 2016 objects.
$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `    -ModifiedObjects $FastFitObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -VersionListPrefixes $VersionListPrefixes `
    -Force

<#
$CompareObject = '*.TXT'
Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -CompareObject $CompareObject -Split
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Merge
Merge-NAVCode -WorkingFolderPath $WorkingFolder -CompareObject $CompareObject -Join

# Join Merged objects to one text file.
Merge-NAVCode -WorkingFolderPath $WorkingFolderNAV2009 -CompareObject $CompareObject -Join
#>

