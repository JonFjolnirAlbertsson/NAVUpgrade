$ServerInstance  = 'NAV90SIDataUpgrade'

Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
$null = Set-NAVServerInstance -Start -ServerInstance $ServerInstance


    if($LicenseFile){  
        Write-Host -ForegroundColor Green -Object 'Importing license..'
        $null = $ServerInstanceObject | Import-NAVServerLicense -LicenseFile $LicenseFile -Force -WarningAction SilentlyContinue
    }
$ServerInstance  = 'NAV71CU29SIData'  
$ServerInstance  = 'DynamicsNAV71'            
$null = sc.exe config (get-service NetTcpPortSharing).Name Start= Auto
$null = Start-service NetTcpPortSharing
$null = sc.exe config (get-service  "*$ServerInstance*").Name depend= HTTP/NetTcpPortSharing
    
Set-NAVServerInstance -ServerInstance $ServerInstance -Restart

Sync-NAVTenant -ServerInstance $ServerInstance -Force
Sync-NAVTenant -ServerInstance $ServerInstance -Force -Mode Force
Sync-NAVTenant -ServerInstance $ServerInstance -Mode CheckOnly

Join-NAVApplicationObjectFile -Source "C:\NAVUpgrade\Customer\SI-Data\NAV 2016\Incadea\Merged\ToBeJoined" -Destination "C:\NAVUpgrade\Customer\SI-Data\NAV 2016\Incadea\all-merged-objects.txt"

Enable-NAVServerInstancePortSharing -ServerInstance $ModifiedServerInstance