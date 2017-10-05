USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJobNotificationEmailList_Failure]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetJobNotificationEmailList_Failure] 
(
 @Separator as varchar(10)
)  
RETURNS Varchar(MAX)
AS 
BEGIN 
	DECLARE @listStr VARCHAR(MAX)

	select @listStr =  dbo.GetNotificationEmailByBusinessRule('Import_Process_Job_Send_To_Failure', @Separator) 

	RETURN ( 
	
		SELECT @listStr
	)
END 



GO
