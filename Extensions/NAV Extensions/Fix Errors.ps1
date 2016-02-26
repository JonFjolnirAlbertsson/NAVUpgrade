 $ServerInstance  = 'SID_DemoExt_DEV'
 $ServerInstance  = 'SID_DemoExt_QA'

 if ($EnablePortSharing) {
        Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
    }

 $null = Set-NAVServerInstance -Start -ServerInstance $ServerInstance
    if($LicenseFile){  
        Write-Host -ForegroundColor Green -Object 'Importing license..'
        $null = $ServerInstanceObject | Import-NAVServerLicense -LicenseFile $LicenseFile -Force -WarningAction SilentlyContinue
    }
            
    if ($EnablePortSharing) {
        Enable-NAVServerInstancePortSharing -ServerInstance $ServerInstance
    }
    
    if ($StartWindowsClient) {
        Start-NAVWindowsClient `
            -Port $ServerInstanceObject.ClientServicesPort `
            -ServerInstance $ServerInstanceObject.ServerInstance `
            -ServerName ([net.dns]::gethostname())
    }

    $Object 