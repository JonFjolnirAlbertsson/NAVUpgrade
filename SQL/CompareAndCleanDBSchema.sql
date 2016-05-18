--delete from [NAVSIData].[dbo].[Object Metadata Snapshot] 

--where [Object ID] in 

--( 2000000007, 2000000009, 2000000020, 2000000022, 

--2000000026, 2000000028, 2000000029, 2000000038, 

--2000000039, 2000000040, 2000000041, 2000000043, 

--2000000044, 2000000045, 2000000048, 2000000049, 

--2000000055, 2000000058, 2000000063, 2000000101, 

--2000000102, 2000000103) 

select db1.[Object ID] "DB1 Table ID", db1.Name "DB1 Table Name", db1.Hash "DB1 Metadata Hash", db2.[Object ID] "DB2 Table ID",db2.Name "DB2 Table Name", db2.Hash "DB2 Metadata Hash" 
from [NAVSIData].[dbo].[Object Metadata Snapshot] db1 full outer join [NAVSIDataDen].[dbo].[Object Metadata Snapshot] db2 on db1.[Object ID] = db2.[Object ID]



delete from [NAVSIDataDen].[dbo].[Object Metadata Snapshot]
where [Object ID] in 
(2000000007, 2000000026, 2000000049, 2000000101, 2000000102, 2000000103, 2000000020, 2000000055, 2000000009, 2000000029, 2000000038, 2000000058, 2000000041, 2000000028,2000000063, 2000000022, 2000000048, 2000000040, 2000000043, 2000000044, 2000000039, 2000000045)

--Recompile all objects


