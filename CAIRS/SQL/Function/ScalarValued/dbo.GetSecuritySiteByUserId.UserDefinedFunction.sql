USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetSecuritySiteByUserId]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetSecuritySiteByUserId] 
(
@Login as varchar(100),
@Separator as varchar(10)
)  
RETURNS Varchar(MAX)
AS 
BEGIN 
DECLARE @listStr VARCHAR(MAX)

select 
	@listStr = COALESCE(@listStr + @Separator,'') + s.Site_Code
from dbo.GetUserSiteSecurity(@Login) s

RETURN ( 
	
	SELECT @listStr
)
END 


GO
