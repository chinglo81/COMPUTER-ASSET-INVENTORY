USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Insert_App_Activity]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Insert_App_Activity]
	@URL AS Varchar(2000),
	@Page_Name AS VARCHAR(1000),
	@Page_Parameter AS VARCHAR(2000),
	@Emp_ID AS VARCHAR(11),
	@Date_Added AS VARCHAR(30),
	@returnid AS INT = null OUTPUT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	INSERT INTO dbo.App_Activity
	(
		URL,
		Page_Name,
		Page_Parameter,
		Emp_ID,
		Date_Added
	)
		
	SELECT	@URL,
			@Page_Name,
			@Page_Parameter,
			@Emp_ID,
			@Date_Added

	SET @returnid = SCOPE_IDENTITY()
	
	SELECT @returnid ReturnValue
END



GO
