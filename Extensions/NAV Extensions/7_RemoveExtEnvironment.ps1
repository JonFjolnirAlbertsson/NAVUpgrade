# Import settings
. (Join-Path $PSScriptRoot '_Settings.ps1') -ErrorAction Stop

Remove-NAVEnvironment -ServerInstance $OriginalServerInstance 
Remove-NAVEnvironment -ServerInstance $ModifiedServerInstanceV1 -BackupModifiedObjectsPath $BackupModifiedObjectsPath
Remove-NAVEnvironment -ServerInstance $TargetServerInstance
