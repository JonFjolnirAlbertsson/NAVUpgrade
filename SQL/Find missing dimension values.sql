
select * from [NAV90CU5Elas].[dbo].[Elas AS$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in 
 (select B.Code from
[NAV90CU5Elas].[dbo].[AS Elas Eiendom$Dimension Value] B)

 select * from [NAV90CU5Elas].[dbo].[AS Elas Eiendom$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (
 select B.Code from
[NAV90CU5Elas].[dbo].[AS Elas Eiendom$Dimension Value] B)

 select * from [NAV90CU5Elas].[dbo].[Sokalbygget AS$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (
 select B.Code from
[NAV90CU5Elas].[dbo].[Sokalbygget AS$Dimension Value] B)