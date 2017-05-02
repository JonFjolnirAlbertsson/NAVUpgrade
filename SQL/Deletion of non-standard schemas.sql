--define database
USE [fastfit_080300_DEALER1_Dev] --Change this!

go

--declare the cursor and the name of the column we want to  
--retrieve from the result set (the name of the schema)
DECLARE @SCHEMADATA AS CURSOR;
DECLARE @SCHEMA_NAME AS NVARCHAR(150);
--declare counter, so we can count the number of items in the result set
DECLARE @COUNTERCURSOR AS CURSOR;
DECLARE @COUNTER AS INT;
--declare the SQL-script we want to run (that will 
--delete non-default schemas)
DECLARE @runSQL VARCHAR(max);

SET @runSQL = '' + Char(10) + Char(10);
--Retrieve number of non-standard schemas
SET @COUNTERCURSOR = CURSOR
FOR SELECT Count(*)
    FROM   INFORMATION_SCHEMA.SCHEMATA
    WHERE  SCHEMA_NAME NOT IN ( 'dbo', 'guest', 'INFORMATION_SCHEMA', 'sys',
                                'db_owner', 'db_accessadmin', 'db_securityadmin'
                                ,'db_ddladmin', 'db_backupoperator', 'db_datareader',
                                'db_datawriter','db_denydatareader','db_denydatawriter' );

OPEN @COUNTERCURSOR;

FETCH FROM @COUNTERCURSOR INTO @COUNTER;

--Print number and status
PRINT 'Number of non-standard schemas: '
      + CONVERT(VARCHAR(10), @COUNTER);

IF @COUNTER > 0
  PRINT 'The following schemas will be deleted: ';
ELSE
  PRINT 'No schemas will be deleted';

--Retrieve non-standard schemas 
SET @SCHEMADATA = CURSOR
FOR SELECT SCHEMA_NAME
    FROM   INFORMATION_SCHEMA.SCHEMATA
    WHERE  SCHEMA_NAME NOT IN ( 'dbo', 'guest', 'INFORMATION_SCHEMA', 'sys',
                                'db_owner', 'db_accessadmin', 'db_securityadmin'
                                ,'db_ddladmin', 'db_backupoperator', 'db_datareader',
                                'db_datawriter', 'db_denydatareader',
                                'db_denydatawriter' );

--Loop through result set (the non-default schemas)
OPEN @SCHEMADATA;

FETCH next FROM @SCHEMADATA INTO @SCHEMA_NAME;

WHILE @@FETCH_STATUS = 0
  BEGIN
      --print name of schema that will be deleted
      PRINT @SCHEMA_NAME;

      --@RunsSQL will now contain the DROP SCHEMA but is not executed
      SET @runSQL = @runSQL + 'DROP SCHEMA [' + @SCHEMA_NAME + ']'
                    + Char(10);

      FETCH next FROM @SCHEMADATA INTO @SCHEMA_NAME;
  END

CLOSE @SCHEMADATA;

DEALLOCATE @SCHEMADATA;

CLOSE @COUNTERCURSOR;

DEALLOCATE @COUNTERCURSOR;

--Print the SQL that will drop the schemas
PRINT @runSQL;
--Execute the drop of the schemas
--EXEC (@runSQL)