
USE [master];
GO

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
BACKUP DATABASE ' + QUOTENAME(name) 
  + ' TO  DISK = N''F:\mssql\backup\WIP\' + QUOTENAME(name) + '.bak''' 
  + '  WITH NOFORMAT, INIT,  NAME = N''' + QUOTENAME(name) + '-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10'
FROM sys.databases 
--WHERE name LIKE N'1%';
WHERE name LIKE N'Inc%';
--WHERE (name LIKE N'NA%') or (LIKE N'1%') OR (LIKE N'Inc%');

PRINT @sql;
EXEC sp_executesql @sql; 

--BACKUP DATABASE [1011_Bydelene_2009] 
--TO  DISK = N'C:\MSSQL\Backup\1011_Bydelene_2009.bak' 
--WITH NOFORMAT, INIT,  NAME = N'1011_Bydelene_2009-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
--GO
