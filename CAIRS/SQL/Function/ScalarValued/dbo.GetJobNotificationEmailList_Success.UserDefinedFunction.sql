USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJobNotificationEmailList_Success]    Script Date: 6/28/2017 11:05:11 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetJobNotificationEmailList_Success] 
(
 @Separator as varchar(10)
)  
RETURNS Varchar(MAX)
AS 
BEGIN 
DECLARE @listStr VARCHAR(MAX)

select 
	@listStr = COALESCE(@listStr + @Separator,'') + isnull(ltrim(rtrim(e.EMailAddress)), bd.Code)
from Business_Rule br
inner join Business_Rule_Detail bd
	on bd.Business_Rule_ID = br.ID
left join Datawarehouse.dbo.Employees e
	on e.empdistid = bd.Code
where br.Code = 'Stu_Device_Coverage_Job_Send_To'
order by
	e.LastName,
	e.FirstName,
	bd.Code

RETURN ( 
	
	SELECT @listStr
)
END 



GO
