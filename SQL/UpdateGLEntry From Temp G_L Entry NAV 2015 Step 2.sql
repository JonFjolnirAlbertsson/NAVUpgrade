USE [NAV80CU17ElasPerfTest]
GO

--SELECT [timestamp]
--      ,[Entry No_]
--      ,[G_L Account No_]
--      ,[Bal_ Account No_]
--  FROM [dbo].[Elas AS$Temp G_L Entry]
--GO

--10:36 - 11:05 
--Running the script takes about 30 min.
--(3188670 row(s) affected)

--Elas AS$
UPDATE [dbo].[Elas AS$G_L Entry]
SET [G_L Account No_] = tempGLEntry.[G_L Account No_]
    ,[Bal_ Account No_] = tempGLEntry.[Bal_ Account No_]
FROM [dbo].[Elas AS$Temp G_L Entry] as tempGLEntry
WHERE
     [dbo].[Elas AS$G_L Entry].[Entry No_] = tempGLEntry.[Entry No_]

--AS Elas Eiendom$
UPDATE [dbo].[AS Elas Eiendom$G_L Entry]
SET [G_L Account No_] = tempGLEntry.[G_L Account No_]
    ,[Bal_ Account No_] = tempGLEntry.[Bal_ Account No_]
FROM [dbo].[AS Elas Eiendom$Temp G_L Entry] as tempGLEntry
WHERE
     [dbo].[AS Elas Eiendom$G_L Entry].[Entry No_] = tempGLEntry.[Entry No_]

--Sokalbygget AS$
UPDATE [dbo].[Sokalbygget AS$G_L Entry]
SET [G_L Account No_] = tempGLEntry.[G_L Account No_]
    ,[Bal_ Account No_] = tempGLEntry.[Bal_ Account No_]
FROM [dbo].[Sokalbygget AS$Temp G_L Entry] as tempGLEntry
WHERE
     [dbo].[Sokalbygget AS$G_L Entry].[Entry No_] = tempGLEntry.[Entry No_]