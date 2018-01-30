﻿# Base Variables
$RootDrive = 'C:\'
$RootFolderPath = join-path $RootDrive 'incadea'
$CompanyName = 'fastfit'
$DBServerRootPath = "\\NO01DEVSQL01\$CompanyName"
$DBServerDemoPath = 'C:\MSSQL\Backup\Demo\'
$GitPath = join-path $RootDrive 'Git'
$GitPathIncadea = join-path  $GitPath "\NAVUpgrade\Customer\incadea"
# Servers
$DBServer = 'NO01DEVSQL01.si-dev.local'
$NAVServer = 'NO01DEV03.si-dev.local'
$NAVLicense = join-path $RootFolderPath "License\incadea.fastfit_8.X (NAV2016)_development_INS-NOR_4805448_20170321.flf"
$CertificateFile = join-path ("$GitPathIncadea\$CompanyName") 'cert'
# $UserName = 'incadea\albertssonf'
$UserName = 'si-dev\devjal'
$DBNAVServiceUserName = 'si-dev\nav_user'
$InstanceUserName = 'nav_user@si-dev.local'
$InstancePassword = '1378Nesbru'
$DBUser = 'NAV_Service'
$UpgradeFromVersion = '083000'
$UpgradeToVersion = '084010'
$NAVVersion = 'NAV2016'
$NAVCU = 'CU17'
$CompanyFolder = "$CompanyName\$UpgradeToVersion"
$RootFolder = join-path $RootFolderPath $CompanyFolder
$WorkingFolder = join-path $RootFolder "\$NAVVersion\$NAVCU\Upgrade_$CompanyName"
$LogPath = join-path $WorkingFolder 'Log'
# Database backup W1
$AppDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_APP'
$DEALER1DBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_DEALER1'
$DEALER2DBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_DEALER2'
$MASTERDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_MASTER'
$REPORTINGDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_REPORTING'
$STAGINGDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_STAGING'
$TEMPLATEDBNameW1 = 'fastfit_' + $UpgradeToVersion + '_W1_TEMPLATE'
$Dealer1TenantW1= 'dealer1w1'
$Dealer2TenantW1= 'dealer2w1'
$MasterTenantW1= 'masterw1'
$ReportingTenantW1= 'reportingw1'
$StagingTenantW1= 'stagingw1'
$TemplateTenantW1= 'templatew1'
$DemoDBW1 = 'Demo Database NAV (9-0) CU17 W1'
# Database backup NO
$UpgradeFromDevDBName = 'fastfit_' + $UpgradeFromVersion + '_NO_DEV'
$UpgradeFromW1DBName = 'fastfit_' + $UpgradeFromVersion + '_W1_APP'
$AppDBNameNODev = 'fastfit_' + $UpgradeToVersion + '_NO_APP_DEV'
$DEALER1DBNameNODev = 'fastfit_' + $UpgradeToVersion + '_NO_DEV'
$AppDBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_APP'
$DEALER1DBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_DEALER1'
$DEALER2DBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_DEALER2'
$MASTERDBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_MASTER'
$REPORTINGDBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_REPORTING'
$STAGINGDBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_STAGING'
$TEMPLATEDBNameNO = 'fastfit_' + $UpgradeToVersion + '_NO_TEMPLATE'
$Dealer1TenantNO= 'dealer1no'
$Dealer2TenantNO= 'dealer2no'
$MasterTenantNO= 'masterno'
$ReportingTenantNO= 'reportingno'
$StagingTenantNO= 'stagingno'
$TemplateTenantNO= 'templateno'
$DemoDBNO = 'Demo Database NAV (9-0) CU17 NO'
# Database backup common
$BackupPath = join-path $DBServerRootPath ($UpgradeToVersion + '_W1\Database Backups')
$BackupfileAppDB = join-path $BackupPath ("$AppDBNameW1.bak")
$BackupfileDEALER1DB = join-path $BackupPath ("$DEALER1DBNameW1.bak")
$BackupfileDEALER2DB = join-path $BackupPath ("$DEALER2DBNameW1 .bak")
$BackupfileMASTERDB = join-path $BackupPath ("$MASTERDBNameW1.bak")
$BackupfileREPORTINGDB = join-path $BackupPath ("$REPORTINGDBNameW1.bak")
$BackupfileSTAGINGDB = join-path $BackupPath ("$STAGINGDBNameW1 .bak")
$BackupfileTEMPLATEDB = join-path $BackupPath ("$TEMPLATEDBNameW1.bak")
$BackupfileDemoDBW1 = join-path $DBServerDemoPath "$DemoDBW1.bak"
$BackupfileDemoDBNO = join-path $DBServerDemoPath "$DemoDBNO.bak"
# NAV Server Instances
$FastFitInstanceNO = 'fastfit_' + $UpgradeToVersion + '_NO'
$FastFitInstanceNODev = 'fastfit_' + $UpgradeToVersion + '_NO_Dev'
$FastFitInstanceW1 = 'fastfit_' + $UpgradeToVersion + '_W1'
$FastFitInstanceUpgradeFromVersionW1 = 'fastfit_' + $UpgradeFromVersion + '_W1'
#$FastFitInstanceUpgradeFromVersionNO = 'fastfit_' + $UpgradeFromVersion + '_NO_Dev'
# Merge files
$OriginalObjects = 'fastfit_' + $UpgradeFromVersion + '_W1.txt'$FastFitObjects = 'fastfit_' + $UpgradeFromVersion + '_NO.txt'
$TargetObjects = 'fastfit_' + $UpgradeToVersion + '_W1.txt'
$OriginalObjectsPath = (join-path $WorkingFolder $OriginalObjects)
$FastFitObjectsPath = (join-path $WorkingFolder $FastFitObjects)
$TargetObjectsPath = (join-path $WorkingFolder $TargetObjects)
$SourcePath = join-path $WorkingFolder 'MergeResult' 
$ConflictTarget = join-path $SourcePath  'ConflictTarget' 
$NAVEnvZupFilePath = 'C:\Incadea\Fastfit\zup'
$NAVZupFilePath = 'C:\Users\DevJAL\AppData\Roaming\fin.zup' 
