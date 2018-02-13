# Client script to start remote session on application server
Set-Location -Path (Split-Path $psise.CurrentFile.FullPath -Qualifier)
$Location = (Split-Path $psise.CurrentFile.FullPath)
$scriptLocationPath = (join-path $Location 'Set-UpgradeSettings.ps1')
. $scriptLocationPath
# Client Enabling WSManCredSSP to be able to do a double hop with authentication.
Enable-WSManCredSSP -Role Client -DelegateComputer $NAVServerRSName  -Force
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName $NAVServerRSName -UseSSL -Credential $UserCredential –Authentication CredSSP

# Server Site script
clear-host
$StartedDateTime = Get-Date
Set-Location 'C:\'
$Location = join-path $pwd.drive.Root 'Git\NAVUpgrade\Customer\PP\Script'
$scriptLocationPath = join-path $Location 'Set-UpgradeSettings.ps1'
. $scriptLocationPath
Import-Certificate -Filepath $CertificateFile -CertStoreLocation "Cert:\LocalMachine\Root"
## Server Enabling WSManCredSSP to be able

# NAV 2015 
#Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
#Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\80\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null 

# NAV 2018 
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -WarningAction SilentlyContinue | Out-Null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null 

#Cloud.Ready.Software and Incadea
$gitpath = "C:\Git"
$scriptfolderpath = "C:\Git\IncadeaNorway"   
Import-module (Join-Path "$gitpath\Cloud.Ready.Software.PowerShell\PSModules" 'LoadModules.ps1')  
Import-module (Join-Path $scriptfolderpath 'LoadModules.ps1')  
# Get Sript config for remote session
$SetupScript = "C:\Git\NAVUpgrade\Customer\PP\Script\Set-UpgradeSettings.ps1"
import-module $SetupScript

$DemoInstance = 'DynamicsNAV80'
$DemoInstance = 'DynamicsNAV110'
$NAV2015Instance = 'NAV80_PP'
$NAV2018Instance = 'NAV110_PP'
$ADUserName = 'si-dev\devjal'
$ADUserName = 'si-dev\devMAF'
$CurrentServerInstance = Get-NAVServerInstance -ServerInstance $NAV2018Instance
$DatabaseName = (Get-NAVServerConfiguration2 -ServerInstance $CurrentServerInstance.ServerInstance | Where Key -eq DatabaseName).Value
$DatabaseServer = (Get-NAVServerConfiguration2 -ServerInstance $CurrentServerInstance.ServerInstance | Where Key -eq DatabaseServer).Value
New-NAVUser-INC -NavServiceInstance $NAV2018Instance -User $ADUserName
New-SQLUser-INC -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -DatabaseUser $ADUserName
#Get-NAVServerInstance -ServerInstance $DemoInstance | Copy-NAVEnvironment -ToServerInstance $NAV2018Instance
#Sync-NAVTenant -ServerInstance $DemoInstance 
Import-NAVServerLicenseToDatabase -LicenseFile $NAVLicense -Scope Database -ServerInstance $DemoInstance
Restart-NAVServerInstance -ServerInstance $DemoInstance
Import-NAVServerLicenseToDatabase -LicenseFile $NAVLicense -Scope Database -ServerInstance $NAV2018Instance
Restart-NAVServerInstance -ServerInstance $NAV2018Instance
