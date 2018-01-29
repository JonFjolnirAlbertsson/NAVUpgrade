# Base Variables
$RootDrive = 'C:\'
$RootFolderPath = join-path $RootDrive 'incadea'
$CompanyName = 'fastfit'
$DBServerRootPath = "\\NO01DEVSQL01\$CompanyName"
$GitPath = join-path $RootDrive 'Git'
$GitPathIncadea = join-path  $GitPath "\NAVUpgrade\Customer\incadea"
# Servers
$DBServer = 'NO01DEVSQL01.si-dev.local'
$NAVServer = 'NO01DEV03.si-dev.local'
$NAVLicense = join-path $GitPath "License\incadea.fastfit_8.X (NAV2016)_development_INS-NOR_4805448_20170321.flf"
$CertificateFile = join-path ("$GitPathIncadea\$CompanyName") 'cert'
# $UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$DBUser = 'NAV_Service'
$UpgradeFromVersion = '083000'
$UpgradeToVersion = '084010'
$CompanyFolder = "$CompanyName\$UpgradeToVersion"
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
# Database backup common
$BackupPath = join-path $DBServerRootPath ($UpgradeToVersion + '_W1\Database Backups')
$BackupfileAppDB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_APP.bak')
$BackupfileDEALER1DB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_DEALER1.bak')
$BackupfileDEALER2DB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_DEALER2.bak')
$BackupfileMASTERDB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_MASTER.bak')
$BackupfileREPORTINGDB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_REPORTING.bak')
$BackupfileSTAGINGDB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_STAGING.bak')
$BackupfileTEMPLATEDB = join-path $BackupPath ('fastfit_' + $UpgradeToVersion + '_W1_TEMPLATE.bak')
# Database backup W1
$AppDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_APP'
$DEALER1DBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_DEALER1'
$DEALER2DBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_DEALER2'
$MasterDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_MASTER'
$REPORTINGDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_REPORTING'
$STAGINGDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_STAGING'
$TEMPLATEDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_TEMPLATE'
$Dealer1TenantW1= 'dealer1w1'
$Dealer1TenantW1= 'dealer2w1'
$MasterTenantW1= 'masterw1'
$ReportingTenantW1= 'reportingw1'
$StagingTenantW1= 'stagingw1'
$TemplateTenantW1= 'templatew1'
# Database backup NO
$UpgradeFromDevDBName = 'fastfit_' + $UpgradeFromVersion + '_NO_DEV'
$UpgradeToDevDBName = 'fastfit_' + $UpgradeToVersion + '_NO_DEV'
$AppDBName = 'fastfit_' + $UpgradeToVersion + '_NO_APP'
$DEALER1DBName = 'fastfit_' + $UpgradeToVersion + '_NO_DEALER1'
$Dealer1Tenant= 'dealer1'
# NAV Server Instances
$FastFitInstance = 'fastfit_' + $UpgradeToVersion + '_NO'
$FastFitInstanceDev = 'fastfit_' + $UpgradeToVersion + '_NO_Dev'
$FastFitInstanceW1 = 'fastfit_' + $UpgradeToVersion + '_W1'
