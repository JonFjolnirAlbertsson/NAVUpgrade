﻿#To start remote session on application server
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$UserName = 'si-dev\devjal'
$InstanceSecurePassword = ConvertTo-SecureString $InstancePassword -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $InstanceSecurePassword 
Enter-PSSession -ComputerName NO01DEV03 -UseSSL -Credential $UserCredential
Import-Certificate -Filepath "C:\Git\NAVUpgrade\Customer\Incadea\FastFit\cert" -CertStoreLocation "Cert:\LocalMachine\Root"

# NAV 2015 
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
#Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -WarningAction SilentlyContinue | Out-Null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\80\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null 
# NAV 2016 
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -WarningAction SilentlyContinue | Out-Null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null 
# NAV 2018 
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -WarningAction SilentlyContinue | Out-Null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null 

$DemoInstance = 'DynamicsNAV80'
$DemoInstance = 'DynamicsNAV110'
$ADUserName = 'si-dev\devjal'
$ADUserName = 'si-dev\devgst'
$ADUserName = 'si-dev\devmaf'
#Sync-NAVTenant -ServerInstance $DemoInstance 
Get-NAVServerInstance $DemoInstance | New-NAVServerUser -WindowsAccount $ADUserName 
Get-NAVServerInstance $DemoInstance | New-NAVServerUserPermissionSet –WindowsAccount $ADUserName -PermissionSetId SUPER -Verbose
