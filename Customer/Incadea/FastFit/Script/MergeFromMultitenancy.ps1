# PURPOSE: This sample script merges an application database and a tenant database that are not part of a multitenant deployment.
### Modify these variables with values appropriate to your environment ###
$serverInstance = "fastfit_080300_APP_Dev"
$appDatabaseName = "fastfit_080300_APP_Dev"
$tenantDatabaseName = "fastfit_080300_DEALER1_Dev"
$DatabaseServer = 'NO01DEVSQL01'
### You should not need to modify any variables below this line ###
# Stop the server instance if it is running.
Set-NAVServerInstance -ServerInstance $serverInstance -Stop
# Remove any application tables from the tenant database if these have not already been removed.
Remove-NAVApplication -DatabaseServer $DatabaseServer -DatabaseName $tenantDatabaseName -Force
# Copy the application tables from the application database to the tenant database.
Export-NAVApplication -DatabaseServer $DatabaseServer -DatabaseName $appDatabaseName -DestinationDatabaseName $tenantDatabaseName
# Reconfigure the CustomSettings.config to use the tenant database.
Set-NAVServerConfiguration -ServerInstance $serverInstance -KeyName DatabaseName -KeyValue $tenantDatabaseName -WarningAction Ignore
# Reconfigure the CustomSettings.config to use single-tenant mode
 Set-NAVServerConfiguration -ServerInstance $serverInstance -KeyName Multitenant -KeyValue false -WarningAction Ignore
# Start the server instance.
Set-NAVServerInstance -ServerInstance $serverInstance -Start
# Dismount all tenants that are not using the current tenant database.
Get-NAVTenant -ServerInstance $serverInstance | where {$_.Database -ne $tenantDatabaseName} | foreach { Dismount-NAVTenant -ServerInstance $serverInstance -Tenant $_.Id }
Write-Host "Operation complete." -foregroundcolor cyan 

$UserName = 'SI-DEV\DEVJAL'
New-NAVServerUser -ServerInstance $serverInstance -WindowsAccount $UserName  -LicenseType Full -State Enabled
New-NAVServerUserPermissionSet -PermissionSetId SUPER -ServerInstance $serverInstance -WindowsAccount $UserName 
Get-NAVServerUser -ServerInstance $serverInstance 