. 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'

.'C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\NavModelTools.ps1' "C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\finsql.exe" 

md c:\workshop
md c:\workshop\ORIGINAL
md c:\workshop\MODIFIED
md c:\workshop\DELTA
cd c:\workshop
dir
#The app
$AppName = 'Demo_Incadea'
$AppPublisher = 'Incadea Norge AS'
$AppDescription = 'DemoNAVINCApp'
$InitialAppVersion = '1.0.0.0'
$OriginalServerInstance = "Shared_ORIG"
$ModifiedServerInstanceV1 = "Demo_DEV_V1"
$ModifiedServerInstanceV2 = "Demo_DEV_V2"
$TargetServerInstance = "Demo_Incadea_Target"
$License = "C:\NAVUpgrade\License\NAV2016.flf"

#Defaults
$DefaultServerInstance = 'DynamicsNAV100'
$BackupPath = [io.path]::GetFullPath((Join-Path $PSScriptRoot '\..\'))
$CopyFromServerInstance = Get-NAVServerInstance $DefaultServerInstance -ErrorAction Stop
$Backupfile = $CopyFromServerInstance | Backup-NAVDatabase -ErrorAction Stop
$CopyFromServerInstance | Enable-NAVServerInstancePortSharing

Remove-NAVEnvironment -ServerInstance $TargetServerInstance 
New-NAVEnvironment -ServerInstance $TargetServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License
 
Export-NAVApplicationObject -Path "ORIGINAL.txt" -DatabaseName $OriginalServerInstance -DatabaseServer 'localhost' -Filter 'ID=27|30' | Split-NAVApplicationObjectFile -Destination .\ORIGINAL 
Export-NAVApplicationObject -Path MODIFIED.txt -DatabaseName $ModifiedServerInstanceV1 -DatabaseServer 'localhost' -Filter 'Modified=Ja' | Split-NAVApplicationObjectFile -Destination .\MODIFIED

Compare-NAVApplicationObject -OriginalPath ORIGINAL -ModifiedPath MODIFIED -DeltaPath DELTA 

Get-Help New-NAVAppManifest

New-NAVAppManifest -Name $AppName -Publisher $AppPublisher -Description $AppDescription | New-NavAppManifestFile -Path MyNAVExt.xml  

Get-NAVAppManifest –Path MyNAVExt.xml | New-NAVAppPackage –Path MyNAVExt.navx –SourcePath DELTA

Get-NAVAppInfo –Path MyNAVExt.navx

move c:\workshop\MODIFIED c:\workshop\MODIFIED-V1
move c:\workshop\DELTA c:\workshop\DELTA-V1

md c:\workshop\MODIFIED
md c:\workshop\DELTA

Export-NAVApplicationObject -Path MODIFIED.txt -DatabaseName $ModifiedServerInstanceV2 -DatabaseServer 'localhost' -Filter 'Modified=Ja' | Split-NAVApplicationObjectFile -Destination .\MODIFIED
Export-NAVAppTenantWebService -ServerInstance $ModifiedServerInstanceV2 -Path .\DELTA\ItemListWebService.xml -ServiceName ItemList -ObjectType Page -ObjectId 31 
Export-NAVAppTableData -ServerInstance $ModifiedServerInstanceV2 -Path ‘.\DELTA’ -TableId 75000
#Export table object 75000
#Export-NAVAppReportLayout -ServerInstance $ModifiedServerInstanceV1 -Path .\DELTA\ReportLayout.layoutdata -LayoutId MS-1016-DEFAULT

Compare-NAVApplicationObject -OriginalPath ORIGINAL -ModifiedPath MODIFIED -DeltaPath DELTA

Export-NAVAppPermissionSet -ServerInstance $ModifiedServerInstanceV2 -Path '.\DELTA\WorkshopPermissionSet.xml' -PermissionSetId "WORKSHOP” 
Compare-NAVApplicationObject -OriginalPath ORIGINAL -ModifiedPath MODIFIED -DeltaPath DELTA 

Get-NAVAppManifest –Path MyNAVExt.xml |
  Set-NAVAppManifest –Version 2.0.0.0  |
    New-NavAppManifestFile -Path MyNAVExtV2.xml  

Get-NAVAppManifest –Path MyNAVExtV2.xml |
     New-NAVAppPackage –Path MyNAVExtV2.navx –SourcePath DELTA

Publish-NAVApp -ServerInstance $TargetServerInstance -Path MyNAVExt.navx -SkipVerification
Get-NAVAppInfo -ServerInstance $TargetServerInstance
Get-NAVAppInfo -ServerInstance $TargetServerInstance –Tenant default
Install-NAVApp -ServerInstance $TargetServerInstance -Name $AppName
Uninstall-NAVApp -ServerInstance $TargetServerInstance -Name $AppName -Tenant default –Version 1.0.0.0 
Unpublish-NAVApp -ServerInstance $TargetServerInstance -Path MyNAVExt.navx 

#F8
#get-help *publish*

Publish-NAVApp -ServerInstance $TargetServerInstance -Path .\MyNAVExtV2.navx -SkipVerification
Get-NAVAppInfo -ServerInstance $TargetServerInstance
Get-NAVAppInfo -ServerInstance $TargetServerInstance –Tenant default

Install-NAVApp -ServerInstance $TargetServerInstance -Name $AppName –Version 2.0.0.0 
Uninstall-NAVApp -ServerInstance $TargetServerInstance -Name $AppName –Version 2.0.0.0 
Unpublish-NAVApp -ServerInstance $TargetServerInstance -Path MyNAVExtV2.navx 



