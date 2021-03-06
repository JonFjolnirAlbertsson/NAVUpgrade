/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [timestamp]
      ,[Entry No_]
      ,[Translate File Line]
      ,[Translate File Line Part 1]
      ,[Character Identifiers]
      ,[Property Id]
      ,[Caption Property Id]
      ,[Max_ Length]
      ,[Object Type]
      ,[Object No_]
      ,[Type]
      ,[Name]
      ,[Captions]
      ,[Language Id]
      ,[Missing Caption]
      ,[Caption 1]
      ,[Caption 2]
      ,[Caption 3]
      ,[Caption 4]
      ,[Calculated Caption 1]
      ,[Calculated Caption 2]
      ,[Calculated Caption 3]
      ,[Calculated Caption 4]
      ,[Calculated Caption Differs]
      ,[Changed]
      ,[Id]
      ,[Caption Entry No_]
      ,[Name Changed]
      ,[Caption Changed]
      ,[C_AL Line No_]
      ,[Added by File]
      ,[No_ of Times]
      ,[Translate Later]
      ,[Comment]
      ,[Name 2]
      ,[Name 3]
      ,[Name 4]
  FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
    --where [Language Id] = 1044 and [Object Type] = 8 
  where [Language Id] = 1044  and [Missing Caption] =  1
  and [Calculated Caption 1] <> ''
  --where [Translate File Line] Like 'N1-P55242-G66-P8629-A1033-L999:'
  --where [Captions]<> 1
    --where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 7
  --where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 3 and ([Type] IN (5,9,13,14,15,17,18,20))
  --where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 8 and ([Type] IN (2,4,5,6,9,13,14,15,17,18,20,23))
  --where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 3 and ([Type] IN (3,7,8,15,16,19,21,22))
   --where [Language Id] = 1044 and [Object Type] = 8 and ([Type] IN (3,7,8,15,16,19,21,22))
   --where [Captions] = 0
  order by Name desc
  --order by Name asc
  go


--Delete from Reports
--delete FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
--  where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 3 and ([Type] IN (3,7,8,15,16,19,21,22))
--  go
--Delete from Pages
--delete FROM [fastfit_083000_NO_Dev].[dbo].[OM - Translation Tool Line]
--  where [Language Id] = 1044  and [Missing Caption] =  1 and [Object Type] = 8 and ([Type] IN (3,7,8,15,16,19,21,22))
--  go