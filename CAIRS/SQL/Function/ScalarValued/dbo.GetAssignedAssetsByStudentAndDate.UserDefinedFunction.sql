USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAssignedAssetsByStudentAndDate]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetAssignedAssetsByStudentAndDate] 
(
	@Student_ID as VARCHAR(20),
	@Date as Date,
	@Separator as VARCHAR(100)
)  
RETURNS Varchar(MAX)
AS 
BEGIN 
	DECLARE @listStr VARCHAR(MAX)

	select 
		@listStr = COALESCE(@listStr + @Separator,'') + v.Asset_Base_Type_Desc + ' - ' + v.Asset_Type_Desc + ' Serial #: ' + v.Serial_Number + ' TAG ID: ' + v.Tag_ID
	from v_Asset_Master_List v
	where 1=1
		and v.Asset_Disposition_ID = 1 --Assigned
		and cast(v.Date_Check_Out as date) <= @Date
		and v.Student_ID = @Student_ID
	order by Asset_Base_Type_Desc

	RETURN ( 
		SELECT @listStr
	)
END 



GO
