 $ServerInstance  = 'SID_DemoExt_Original'
 $ServerInstance  = 'SID_DemoExt_DEV'
 $ServerInstance  = 'SID_DemoExt_QA'
  $ServerInstance  = 'DynamicsNAV71'

 Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
 $null = Set-NAVServerInstance -Start -ServerInstance $ServerInstance


    if($LicenseFile){  
        Write-Host -ForegroundColor Green -Object 'Importing license..'
        $null = $ServerInstanceObject | Import-NAVServerLicense -LicenseFile $LicenseFile -Force -WarningAction SilentlyContinue
    }
$ServerInstance  = 'DynamicsNAV70'            
$null = sc.exe config (get-service NetTcpPortSharing).Name Start= Auto
$null = Start-service NetTcpPortSharing
$null = sc.exe config (get-service  "*$ServerInstance*").Name depend= HTTP/NetTcpPortSharing
    
Set-NAVServerInstance -ServerInstance $ServerInstance -Start