USE NAV80CU17ElasPerfTest;
GO
--AS Elas Eiendom$
ALTER TABLE [AS Elas Eiendom$G_L Entry]
  DROP COLUMN
    [G_L Account No_],
    [Bal_ Account No_];

exec sp_rename
  'dbo.[AS Elas Eiendom$G_L Entry].[Temp GLAccountNo]',
  'G_L Account No_',
  'COLUMN';
exec sp_rename
  'dbo.[AS Elas Eiendom$G_L Entry].[Temp BalAccountNo]',
  'Bal_ Account No_',
  'COLUMN';

ALTER TABLE [AS Elas Eiendom$G_L Entry]
  ADD
    [Temp GLAccountNo] [varchar](20) NOT NULL CONSTRAINT [AS Elas Eiendom$def_gl] DEFAULT '',
    [Temp BalAccountNo] [varchar](20) NOT NULL CONSTRAINT [AS Elas Eiendom$def_bal] DEFAULT '';
ALTER TABLE [Company1$G_L Entry]
  DROP CONSTRAINT
    [AS Elas Eiendom$def_gl],
    [AS Elas Eiendom$ef_bal]

--Sokalbygget AS$
ALTER TABLE [Sokalbygget AS$G_L Entry]
  DROP COLUMN
    [G_L Account No_],
    [Bal_ Account No_];

exec sp_rename
  'dbo.[Sokalbygget AS$G_L Entry].[Temp GLAccountNo]',
  'G_L Account No_',
  'COLUMN';
exec sp_rename
  'dbo.[Sokalbygget AS$G_L Entry].[Temp BalAccountNo]',
  'Bal_ Account No_',
  'COLUMN';

ALTER TABLE [Sokalbygget AS$G_L Entry]
  ADD
    [Temp GLAccountNo] [varchar](20) NOT NULL CONSTRAINT [Sokalbygget AS$def_gl] DEFAULT '',
    [Temp BalAccountNo] [varchar](20) NOT NULL CONSTRAINT [Sokalbygget AS$def_bal] DEFAULT '';
ALTER TABLE [Company1$G_L Entry]
  DROP CONSTRAINT
    [Sokalbygget AS$def_gl],
    [Sokalbygget AS$ef_bal]

--Elas AS$
ALTER TABLE [Elas AS$G_L Entry]
  DROP COLUMN
    [G_L Account No_],
    [Bal_ Account No_];

exec sp_rename
  'dbo.[Elas AS$G_L Entry].[Temp GLAccountNo]',
  'G_L Account No_',
  'COLUMN';
exec sp_rename
  'dbo.[Elas AS$G_L Entry].[Temp BalAccountNo]',
  'Bal_ Account No_',
  'COLUMN';

ALTER TABLE [Elas AS$G_L Entry]
  ADD
    [Temp GLAccountNo] [varchar](20) NOT NULL CONSTRAINT [Elas AS$def_gl] DEFAULT '',
    [Temp BalAccountNo] [varchar](20) NOT NULL CONSTRAINT [Elas AS$def_bal] DEFAULT '';
ALTER TABLE [Company1$G_L Entry]
  DROP CONSTRAINT
    [Elas AS$def_gl],
    [Elas AS$ef_bal]