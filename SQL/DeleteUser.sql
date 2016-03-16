use [NAV2015CU8_SIData]
go

DECLARE @UserToDelete nvarchar(30); 
SET @UserToDelete = 'SI-DATA\FDA'; 
--SELECT @find = 'SI-DATA\FDA'; 

delete
from
[dbo].[User] 
where [user].[User Name] = @UserToDelete 

delete
from
[dbo].[Access Control]
where [Access Control].[User Security ID] = (select [User Name] from [dbo].[User] where [user].[User Name] = @UserToDelete)

delete
from
[dbo].[User Property]
where [User Property].[User Security ID] = (select [User Name] from [dbo].[User] where [user].[User Name] = @UserToDelete)

 delete
from
[dbo].[Page Data Personalization]
where [Page Data Personalization].[User SID] =  (select [User Name] from [dbo].[User] where [user].[User Name] = @UserToDelete)

delete from
[dbo].[User Default Style Sheet]
where [User Default Style Sheet].[User ID] =   (select [User Name] from [dbo].[User] where [user].[User Name] = @UserToDelete)

delete from
[dbo].[User Metadata]
where [User Metadata].[User SID] =  (select [User Name] from [dbo].[User] where [user].[User Name] = @UserToDelete)

delete from
[dbo].[User Personalization] 
where [User Personalization].[User SID] =  (select [User Name] from [dbo].[User] where [user].[User Name] = @UserToDelete)
