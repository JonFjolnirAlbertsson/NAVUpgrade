USE NAV80CU17ElasPerfTest;
GO
--AS Elas Eiendom$
ALTER TABLE [AS Elas Eiendom$G_L Entry]
  DROP COLUMN
    [Temp GLAccountNo],
    [Temp BalAccountNo];

exec sp_rename
  'dbo.[AS Elas Eiendom$G_L Entry].[G_L Account No_]',
  'Temp GLAccountNo',
  'COLUMN';
exec sp_rename
  'dbo.[AS Elas Eiendom$G_L Entry].[Bal_ Account No_]',
  'Temp BalAccountNo',
  'COLUMN';

ALTER TABLE [AS Elas Eiendom$G_L Entry]
  ADD
    [G_L Account No_] [varchar](20) NOT NULL CONSTRAINT [AS Elas Eiendom$def_gl] DEFAULT '',
    [Bal_ Account No_] [varchar](20) NOT NULL CONSTRAINT [AS Elas Eiendom$def_bal] DEFAULT '';
ALTER TABLE [AS Elas Eiendom$G_L Entry]
  DROP CONSTRAINT
    [AS Elas Eiendom$def_gl],
    [AS Elas Eiendom$def_bal]

--Sokalbygget AS$
ALTER TABLE [Sokalbygget AS$G_L Entry]
  DROP COLUMN
    [Temp GLAccountNo],
    [Temp BalAccountNo];

exec sp_rename
  'dbo.[Sokalbygget AS$G_L Entry].[G_L Account No_]',
  'Temp GLAccountNo',
  'COLUMN';
exec sp_rename
  'dbo.[Sokalbygget AS$G_L Entry].[Bal_ Account No_]',
  'Temp BalAccountNo',
  'COLUMN';

ALTER TABLE [Sokalbygget AS$G_L Entry]
  ADD
    [G_L Account No_] [varchar](20) NOT NULL CONSTRAINT [Sokalbygget AS$def_gl] DEFAULT '',
    [Bal_ Account No_] [varchar](20) NOT NULL CONSTRAINT [Sokalbygget AS$def_bal] DEFAULT '';
ALTER TABLE [Sokalbygget AS$G_L Entry]
  DROP CONSTRAINT
    [Sokalbygget AS$def_gl],
    [Sokalbygget AS$def_bal]

--Elas AS$
ALTER TABLE [Elas AS$G_L Entry]
  DROP COLUMN
    [Temp GLAccountNo],
    [Temp BalAccountNo];

exec sp_rename
  'dbo.[Elas AS$G_L Entry].[G_L Account No_]',
  'Temp GLAccountNo',
  'COLUMN';
exec sp_rename
  'dbo.[Elas AS$G_L Entry].[Bal_ Account No_]',
  'Temp BalAccountNo',
  'COLUMN';

ALTER TABLE [Elas AS$G_L Entry]
  ADD
    [G_L Account No_] [varchar](20) NOT NULL CONSTRAINT [Elas AS$def_gl] DEFAULT '',
    [Bal_ Account No_] [varchar](20) NOT NULL CONSTRAINT [Elas AS$def_bal] DEFAULT '';
ALTER TABLE [Elas AS$G_L Entry]
  DROP CONSTRAINT
    [Elas AS$def_gl],
    [Elas AS$def_bal]