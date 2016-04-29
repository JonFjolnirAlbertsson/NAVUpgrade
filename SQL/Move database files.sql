ALTER DATABASE NAV60ELAS SET OFFLINE;
ALTER DATABASE NAV60ELAS MODIFY FILE ( NAME = 'Demo Database NAV (6-0)_Data', FILENAME = 'F:\data\NAV60Elas_1.mdf' );
ALTER DATABASE NAV60ELAS MODIFY FILE ( NAME = 'Demo Database NAV (6-0)_Log', FILENAME = 'G:\logs\NAV60Elas_2.ldf' );
ALTER DATABASE NAV60ELAS SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NAV60ELAS');

ALTER DATABASE [1046_OsloFiner_Nav2016_CU4] SET OFFLINE;
ALTER DATABASE [1046_OsloFiner_Nav2016_CU4] MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Data', FILENAME = 'F:\data\1046_OsloFiner_Nav2016_CU4_1.mdf' );
ALTER DATABASE [1046_OsloFiner_Nav2016_CU4] MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Log', FILENAME = 'G:\logs\1046_OsloFiner_Nav2016_CU4_2.ldf' );
ALTER DATABASE [1046_OsloFiner_Nav2016_CU4] SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'1046_OsloFiner_Nav2016_CU4');

ALTER DATABASE NAVBusch SET OFFLINE;
ALTER DATABASE NAVBusch MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Data', FILENAME = 'F:\data\1046_OsloFiner_Nav2016_CU4_1.mdf' );
ALTER DATABASE NAVBusch MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Log', FILENAME = 'G:\logs\1046_OsloFiner_Nav2016_CU4_2.ldf' );
ALTER DATABASE NAVBusch SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NAVBusch');

ALTER DATABASE NAV90CU5ElasObjects SET OFFLINE;
ALTER DATABASE NAV90CU5ElasObjects MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Data', FILENAME = 'F:\data\NAV90CU5ElasObjects_1.mdf' );
ALTER DATABASE NAV90CU5ElasObjects MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Log', FILENAME = 'G:\logs\NAV90CU5ElasObjects_2.ldf' );
ALTER DATABASE NAV90CU5ElasObjects SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NAV90CU5ElasObjects');

ALTER DATABASE NAV90CU5Elas SET OFFLINE;
ALTER DATABASE NAV90CU5Elas MODIFY FILE ( NAME = 'Navision50_Data', FILENAME = 'F:\data\NAV90CU5Elas_1.mdf' );
ALTER DATABASE NAV90CU5Elas MODIFY FILE ( NAME = 'Navision50_Log', FILENAME = 'G:\logs\NAV90CU5Elas_2.ldf' );
ALTER DATABASE NAV90CU5Elas MODIFY FILE ( NAME = 'Navision50_1_Data', FILENAME = 'F:\data\NAV90CU5Elas_3.ndf' );
ALTER DATABASE NAV90CU5Elas SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NAV90CU5Elas');

ALTER DATABASE NAV80CU17Elas SET OFFLINE;
ALTER DATABASE NAV80CU17Elas MODIFY FILE ( NAME = 'Demo Database NAV (8-0)_Data', FILENAME = 'F:\data\NAV80CU17Elas_1.mdf' );
ALTER DATABASE NAV80CU17Elas MODIFY FILE ( NAME = 'Demo Database NAV (8-0)_Log', FILENAME = 'G:\logs\NAV80CU17Elas_2.ldf' );
ALTER DATABASE NAV80CU17Elas SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NAV80CU17Elas');

ALTER DATABASE [Demo Database NAV (8-0) CU17] SET OFFLINE;
ALTER DATABASE [Demo Database NAV (8-0) CU17] MODIFY FILE ( NAME = 'Demo Database NAV (8-0)_Data', FILENAME = 'F:\data\DemoDatabaseNAV(8-0)CU17_1.mdf' );
ALTER DATABASE [Demo Database NAV (8-0) CU17] MODIFY FILE ( NAME = 'Demo Database NAV (8-0)_Log', FILENAME = 'G:\logs\DemoDatabaseNAV(8-0)CU17_2.ldf' );
ALTER DATABASE [Demo Database NAV (8-0) CU17] SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'Demo Database NAV (8-0) CU17');

ALTER DATABASE [Demo Database NAV (9-0) CU5] SET OFFLINE;
ALTER DATABASE [Demo Database NAV (9-0) CU5] MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Data', FILENAME = 'F:\data\DemoDatabaseNAV(9-0)CU5_1.mdf' );
ALTER DATABASE [Demo Database NAV (9-0) CU5] MODIFY FILE ( NAME = 'Demo Database NAV (9-0)_Log', FILENAME = 'G:\logs\DemoDatabaseNAV(9-0)CU5_2.ldf' );
ALTER DATABASE [Demo Database NAV (9-0) CU5] SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'Demo Database NAV (9-0) CU5');