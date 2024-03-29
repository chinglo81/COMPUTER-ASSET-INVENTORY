USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetSecuritySiteDescByUserId]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetSecuritySiteDescByUserId] 
(
@Login as varchar(100),
@Separator as varchar(10)
)  
RETURNS Varchar(MAX)
AS 
BEGIN 
DECLARE @listStr VARCHAR(MAX)

select 
	@listStr = COALESCE(@listStr + @Separator,'') + s.Site_Code + ' - ' + s.Site_Desc 
from dbo.GetUserSiteSecurity(@Login) s

RETURN ( 
	
	SELECT @listStr
)
END 



GO
