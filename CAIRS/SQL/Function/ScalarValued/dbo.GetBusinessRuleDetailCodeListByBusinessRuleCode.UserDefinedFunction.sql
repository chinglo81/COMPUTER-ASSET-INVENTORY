USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetBusinessRuleDetailCodeListByBusinessRuleCode]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetBusinessRuleDetailCodeListByBusinessRuleCode] 
(
 @Business_Rule_Code as VARCHAR(100),
 @Separator as varchar(10)
)  
RETURNS Varchar(MAX)
AS 
BEGIN 
DECLARE @listStr VARCHAR(MAX)

select 
	@listStr = COALESCE(@listStr + @Separator,'') + ltrim(rtrim(bd.Code))
from Business_Rule br
inner join Business_Rule_Detail bd
	on bd.Business_Rule_ID = br.ID

where br.Code = @Business_Rule_Code
order by
	bd.Code

RETURN ( 
	
	SELECT @listStr
)
END 



GO
