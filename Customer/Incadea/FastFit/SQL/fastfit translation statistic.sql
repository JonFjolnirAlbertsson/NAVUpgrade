/****** Script for SelectTopNRows command from SSMS  ******/
--Distinct language Id in table
SELECT distinct [Language Id] 
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  go
--Number of lines in table
SELECT count([Entry No_]) AS "All" 
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
GO
--Number of lines group by Language Id
SELECT [Language Id], count([Entry No_]) as 'No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  group by [Language Id] 
GO

--Number of lines filtered by Missing Caption, group by Language Id
SELECT [Language Id], count([Entry No_]) as 'No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Missing Caption] =  1
  group by [Language Id] 
go

--Number of lines filtered by Missing Caption and NOR, group by Language Id
SELECT count([Entry No_]) as 'No. of Lines', [Language Id] 
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Language Id] = 1044  and [Missing Caption] =  1
  group by [Language Id] 
go
--All missing lines group by Object Type
SELECT count([Entry No_]) as 'No. of Lines', [Object Type]
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Language Id] = 1044  and [Missing Caption] =  1
  --and [Captions] > 0
  --and [Calculated Caption 1] = ''
  group by [Object Type]
go
--All Text in reports
SELECT count(*) As 'Reports'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 3 and ([Type] IN (5,9,13,14,15,17,18,20))
and [Captions] > 0
go
--All Text in pages
SELECT count(*) As 'Pages'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 8 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
and [Captions] > 0
go
--All Text in menus
SELECT count(*) As 'Menus'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 7 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
and [Captions] > 0
go
go
--All Text in menus
SELECT count(*) As 'Codeunits'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 5 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
and [Captions] > 0
go

--Distinct Captions in English (1033) language
select count(distinct ([Caption 1])) 
 FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
 where [Language Id] = 1033

--Number of lines with changed captions 
SELECT count([Entry No_]) as 'No. of Lines'
--select *
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Caption Changed] = 1
--Number of lines with changed captions Group by Language Id and Object Type
SELECT [Language Id],[Object Type], count([Entry No_]) as 'No. of Lines'
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
  where [Caption Changed] = 1
  group by [Language Id],[Object Type]
