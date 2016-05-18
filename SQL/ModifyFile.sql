USE master;
GO
ALTER DATABASE NAV60ElasToBeUpgraded MODIFY FILE
    (NAME = Navision50_Log,
	NEWNAME = NAV60ElasToBeUpgraded_Log,
	FILENAME = 'G:\logs\NAV60ElasToBeUpgraded_2.ldf',
    FILEGROWTH = 1000MB);
GO
ALTER DATABASE NAV60ElasToBeUpgraded MODIFY FILE
    (NAME = Navision50_Data,
	NEWNAME = NAV60ElasToBeUpgraded_Data,
	FILENAME = 'F:\data\NAV60ElasToBeUpgraded_1.mdf',
    FILEGROWTH = 1000MB);
GO
ALTER DATABASE NAV60ElasToBeUpgraded MODIFY FILE
    (NAME = Navision50_1_Data,
	NEWNAME = NAV60ElasToBeUpgraded_1_Data,
	FILENAME = 'F:\data\NAV60ElasToBeUpgraded_3.ndf',
    FILEGROWTH = 5000MB);
GO
