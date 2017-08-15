USE [master]
GO
CREATE DATABASE [Demo Database NAV (6-0)] 
ON 
( FILENAME = N'C:\MSSQL\Data\Demo Database NAV (6-0)_Data.mdf' ),
( FILENAME = N'C:\MSSQL\Log\Demo Database NAV (6-0)_Log.ldf' )
 FOR ATTACH
GO
CREATE DATABASE [AXnorth] 
ON 
( FILENAME = N'C:\MSSQL\Data\AXnorth.mdf' ),
( FILENAME = N'C:\MSSQL\Log\AXnorth_log.ldf' )
 FOR ATTACH
GO
CREATE DATABASE [Nav2009_Overaasen] 
ON 
( FILENAME = N'C:\MSSQL\Data\Nav2009_Overaasen_Data.mdf' ),
( FILENAME = N'C:\MSSQL\Data\Nav2009_Overaasen_1_Data.ndf' ),
( FILENAME = N'C:\MSSQL\Log\Nav2009_Overaasen_Log.ldf' )
 FOR ATTACH
GO