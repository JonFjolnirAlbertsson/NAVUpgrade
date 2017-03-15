Invoke-Expression (Invoke-WebRequest https://git.io/vn1hQ)


Restore-DbaDatabase -SqlServer localhost -Path C:\MSSQL\Data\AXnorth.mdf -DestinationDataDirectory C:\MSSQL\Data -DestinationLogDirectory C:\MSSQL\Log 

Get-DbaDatabase -SqlInstance Server1 | Backup-DbaDatabase -Type Full -BackupDirectory \\Server2\share\DbBackups

