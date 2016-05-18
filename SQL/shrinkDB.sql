
backup Database NAV80CU17ElasPerfTest to disk='NUL'
backup log NAV80CU17ElasPerfTest to disk='NUL'

USE NAV80CU17ElasPerfTest;
GO
dbcc shrinkfile([NAV80CU17ElasPerfTest_Log], 5000)
GO

