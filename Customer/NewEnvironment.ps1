$DefaultServerInstance = 'DynamicsNAV100'
$NewServerInstance = 'NAV100Elas'
$License = 'C:\NAVUpgrade\License\NAV2016.flf'
$CopyFromServerInstance = Get-NAVServerInstance $DefaultServerInstance -ErrorAction Stop

$Backupfile = $CopyFromServerInstance | Backup-NAVDatabase -ErrorAction Stop

$CopyFromServerInstance | Enable-NAVServerInstancePortSharing


#MODIFIED (DEV)
New-NAVEnvironment -ServerInstance $NewServerInstance -BackupFile $Backupfile -ErrorAction Stop -EnablePortSharing -LicenseFile $License
