#Base Variables
$RootDrive = 'C:\'
$RootFolderPath = join-path $RootDrive 'incadea'
$CompanyName = 'fastfit'
$DBServerRootPath = "\\NO01DEVSQL01\$CompanyName"
$GitPath = join-path $RootDrive 'Git'
$GitPathIncadea = join-path  $GitPath "\NAVUpgrade\Customer\incadea"
#Servers
$DBServer = 'NO01DEVSQL01.si-dev.local'
$NAVServer = 'NO01DEV03.si-dev.local'
$NAVLicense = join-path $GitPath "License\incadea.fastfit_8.X (NAV2016)_development_INS-NOR_4805448_20170321.flf"
$CertificateFile = join-path ("$GitPathIncadea\$CompanyName") 'cert'
#$UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$DBUser = 'NAV_Service'
#$VersionFolder = '083000'
$VersionFolder = '084010'
$CompanyFolder = "$CompanyName\$VersionFolder"
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
#Database backup files
$BackupPath = join-path $DBServerRootPath "$VersionFolder\Database Backups"
$AppDBName = 'fastfit_' + $VersionFolder + '_NO_APP'
$AppDBNameW1 = 'fastfit_' + $VersionFolder + '_W1_APP'
$BackupfileAppDB = join-path $BackupPath ('fastfit_' + $VersionFolder + 'W1_APP.bak')
$DEALER1DBName = 'fastfit_' + $VersionFolder + '_NO_DEALER1'
$DEALER1DBNameW1 = 'fastfit_' + $VersionFolder + '_W1_DEALER1'
$BackupfileDEALER1DB = join-path $BackupPath ('fastfit_' + $VersionFolder + 'W1_DEALER1.bak')
$Dealer1Tenant= 'dealer1'
$Dealer1TenantW1= 'dealer1w1'
$FastFitInstance = 'fastfit_' + $VersionFolder + '_NO'
$FastFitInstanceDev = 'fastfit_' + $VersionFolder + '_NO_Dev'
$FastFitInstanceW1 = 'fastfit_' + $VersionFolder + '_W1'
