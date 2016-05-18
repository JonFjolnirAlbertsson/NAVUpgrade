USE [NAVSIData]
GO

INSERT INTO [dbo].[Test 1$Product]
           ([Produktkode]
           ,[Produktnavn]
           ,[Produkttype]
           ,[Produktansvarlig]
           ,[Varenr_]
           ,[Default Task Code])
	SELECT  [Produktkode]
           ,[Produktnavn]
           ,[Produkttype]
           ,[Produktansvarlig]
           ,[Varenr_]
           ,[Default Task Code]
 FROM [Nav50].[dbo].[SI-Data A_S$Produkt];
GO


