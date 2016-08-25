$ServerInstance  = 'NAV90SIDataUpgrade'

Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
$null = Set-NAVServerInstance -Start -ServerInstance $ServerInstance


    if($LicenseFile){  
        Write-Host -ForegroundColor Green -Object 'Importing license..'
        $null = $ServerInstanceObject | Import-NAVServerLicense -LicenseFile $LicenseFile -Force -WarningAction SilentlyContinue
    }
$ServerInstance  = 'NAV71CU29SIData'  
$ServerInstance  = 'NAV71SIData'  
$ServerInstance  = 'DynamicsNAV71'            
$null = sc.exe config (get-service NetTcpPortSharing).Name Start= Auto
$null = Start-service NetTcpPortSharing
$null = sc.exe config (get-service  "*$ServerInstance*").Name depend= HTTP/NetTcpPortSharing
    
Set-NAVServerInstance -ServerInstance $ServerInstance -Restart

Sync-NAVTenant -ServerInstance $ServerInstance -Force
Sync-NAVTenant -ServerInstance $ServerInstance -Force -Mode Force
Sync-NAVTenant -ServerInstance $ServerInstance -Mode CheckOnly

Join-NAVApplicationObjectFile -Source "C:\NAVUpgrade\Customer\SI-Data\NAV 2016\Incadea\Merged\ToBeJoined" -Destination "C:\NAVUpgrade\Customer\SI-Data\NAV 2016\Incadea\all-merged-objects.txt"

New-NAVServerInstance -ManagementServicesPort 7045 -ServerInstance $ServerInstance -ClientServicesCredentialType Windows -ClientServicesPort 7046 -DatabaseName $UpgradeName -DatabaseServer $DBServer -ODataServicesPort 7048 -SOAPServicesPort 7047
Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance

Export-NAVData -DatabaseServer JALW8 -DatabaseName 'Demo Database NAV (9-0) CU4' -FileName 'C:\temp\Demo Database NAV (9-0) CU4.navdata' -AllCompanies -IncludeApplicationData -IncludeGlobalData -IncludeApplication
Import-NAVData -DatabaseServer SQL02 -DatabaseName 'NAV (9-0) CU4' -AllCompanies -FileName 'C:\temp\Demo Database NAV (9-0) CU4.navdata' -IncludeGlobalData -IncludeApplicationData -IncludeApplication

$ServerInstance  = 'NAV71SIData'  
$User = 'si-data\jal'
Get-NAVServerInstance $ServerInstance | New-NAVServerUserPermissionSet -PermissionSetId SUPER -WindowsAccount $User

New-NAVEnvironment -ServerInstance 'NAV90SIDataSQL02' -BackupFile '' -EnablePortSharing -LicenseFile $NAVLicense