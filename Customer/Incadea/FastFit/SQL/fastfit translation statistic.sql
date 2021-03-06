/****** Script for SelectTopNRows command from SSMS  ******/
--Distinct language Id in table
SELECT distinct [Language Id] 
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  go
--Number of lines in table
SELECT count([Entry No_]) AS 'Number of lines in table'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
GO
--Number of lines group by Language Id
SELECT [Language Id], count([Entry No_]) as 'No. of Lines group by Language Id'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  group by [Language Id] 
GO

--Number of lines filtered by Missing Caption, group by Language Id
SELECT [Language Id], count([Entry No_]) as 'Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Missing Caption] =  1
  group by [Language Id] 
go

--Number of lines filtered by Missing Caption and NOR, group by Language Id
SELECT [Language Id], count([Entry No_]) as 'Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Language Id] = 1044  and [Missing Caption] =  1
  group by [Language Id] 
go
--All missing lines group by Object Type
SELECT [Object Type], count([Entry No_]) as 'Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Language Id] = 1044  and [Missing Caption] =  1
  --and [Captions] > 0
  --and [Calculated Caption 1] = ''
  group by [Object Type]
go
--All Text in reports
SELECT count(*) As 'Reports Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 3 and ([Type] IN (5,9,13,14,15,17,18,20))
and [Captions] > 0
go
--All Text in pages
SELECT count(*) As 'Pages Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 8 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
and [Captions] > 0
go
--All Text in menus
SELECT count(*) As 'Menus Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 7 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
and [Captions] > 0
go
go
--All Text in Codeunits
SELECT count(*) As 'Codeunits Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 5 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
and [Captions] > 0
go

--Distinct Captions in English (1033) language
select count(distinct ([Caption 1])) as 'Distinct Captions in English No. of Lines'
 FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
 where [Language Id] = 1033

--Number of lines with changed captions 
SELECT count([Entry No_]) as 'Caption Changed No. of Lines'
--select *
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Caption Changed] = 1
--Number of lines with changed captions Group by Language Id and Object Type
SELECT [Language Id],[Object Type], count([Entry No_]) as 'Caption Changed No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Caption Changed] = 1
  group by [Language Id],[Object Type]
 go

--Total lines in Incadea Translation Tool
SELECT count(*) as 'Incadea Translation Tool No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[W1 Dealer 1$Translation Line Inc_]
go
--Total lines in Incadea Translation Tool
SELECT count(*) as 'Incadea Translation Tool Missing Caption No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[W1 Dealer 1$Translation Line Inc_]
  where [Translated] = 0
go
--Distinct number of texts in Incadea Translation Tool
SELECT count(distinct [Base Text]) as 'Incadea Translation Tool No. distinct Base Text'
  FROM [fastfit_083000_NO_Dev].[dbo].[W1 Dealer 1$Translation Line Inc_]
go
--Distinct number of texts in Incadea Translation Tool
SELECT count(distinct [Translation]) as 'Incadea Translation Tool No. distinct Translation'
  FROM [fastfit_083000_NO_Dev].[dbo].[W1 Dealer 1$Translation Line Inc_]
go

--Distinct number of texts group by Language Id
SELECT [Language Id], count(distinct [Caption 1]) as 'No. distinct Caption 1'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  group by [Language Id]
go

 --Distinct number of texts group by Language Id in standard NAV 2016
SELECT [Language Id], count(distinct [Caption 1]) as 'No. distinct Caption 1 in standard NAV 2016'
  FROM [NAV100CU3_Overaasen].[dbo].[OM - Translation Tool Line]
  group by [Language Id]
go