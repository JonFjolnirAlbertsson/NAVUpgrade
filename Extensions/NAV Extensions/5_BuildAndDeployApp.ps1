# Import settings
. (Join-Path $PSScriptRoot '_Settings.ps1')

#Create NAVX
$StartedDateTime = Get-Date

Write-Host 'Creating NavX Package.. ' -ForegroundColor Green
$AppPackage = Create-NAVXFromDB `
                    -AppName $AppName `                    -BuildFolder $NavAppWorkingFolder `
                    -OriginalServerInstance $OriginalServerInstance `
                    -ModifiedServerInstance $ModifiedServerInstanceV1 `
                    -InitialVersion $InitialAppVersion `
                    -AppDescription $AppDescription `
                    -AppPublisher $AppPublisher `
                    -PermissionSetId $AppName `                    -BackupPath $BackupPath `
                    -ErrorAction Stop `
                    -IncludeFilesInNavApp $IncludeFilesInNavApp

# Install NAV Package
Write-Host 'Installing NavX Package.. ' -ForegroundColor Green
$InstalledApp = Deploy-NAVXPackage `
                    -PackageFile $AppPackage.PackageFile `
                    -ServerInstance $TargetServerInstance `
                    -Tenant $TargetTenant `
                    -Force `
                    -Verbose `                    -SkipVerification

$StoppedDateTime = Get-Date
Write-Host 'Total Duration' ([Math]::Round(($StoppedDateTime - $StartedDateTime).TotalSeconds)) 'seconds' -ForegroundColor Green

#Open RTC Test-environment
$CompanyName = (Get-NAVCompany -ServerInstance $TargetServerInstance -Tenant $TargetTenant)[0].CompanyName
Start-NAVWindowsClient -ServerName ([net.dns]::GetHostName()) -ServerInstance $TargetServerInstance -Companyname $CompanyName

#. (Join-Path 'C:\GitHub\NAVUpgrade\Extensions\NAV Extensions' '_Settings.ps1')

#Uninstall-NAVApp -AppName $AppName -ServerInstance $TargetServerInstance -Tenant $TargetTenant -Force -Verbose

#Unpublish-NAVApp -Name $AppName -ServerInstance $TargetServerInstance

#Publish-NAVApp -ServerInstance $TargetServerInstance  -Path $AppPackage.PackageFile
#Install-NAVApp -ServerInstance $TargetServerInstance  -Path $AppPackage.PackageFile -Tenant $TargetTenant -Force -Verbose
