#To start remote session on application server
$Location = 'C:\Git\NAVUpgrade\Customer\Incadea\FastFit\Script\'
#. (join-path $Location 'Set-UpgradeSettings.ps1')
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettings.ps1')
. $scriptLocationPath
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName NO01DEV03 -UseSSL -Credential $UserCredential
Import-Certificate -Filepath "C:\Git\NAVUpgrade\Customer\Incadea\FastFit\cert" -CertStoreLocation "Cert:\LocalMachine\Root"

$Location = 'C:\Git\NAVUpgrade\Customer\Incadea\FastFit\Script\'
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettings.ps1')
. $scriptLocationPath
 
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -WarningAction SilentlyContinue | Out-Null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null 

Sync-NAVTenant -ServerInstance $FastFitInstanceDev