USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Insert_Audit_Log]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Insert_Audit_Log]
	@Table_Name as Varchar(100),
	@Primary_Key_ID AS INT,
	@Column_Name AS VARCHAR(100),
	@Column_Name_Desc as VARCHAR(100),
	@Old_Value AS VARCHAR(1000),
	@Old_Value_Desc AS VARCHAR(1000),
	@New_Value AS VARCHAR(1000),
	@New_Value_Desc AS VARCHAR(1000),
	@Emp_ID AS VARCHAR(11) ,
	@Date_Modified AS VARCHAR(30)
AS
BEGIN
	-- Return Value
	DECLARE @returnid int
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	BEGIN
		INSERT INTO dbo.Audit_Log
		(
			Table_Name, 
			Primary_Key_ID, 
			Column_Name, 
			Column_Name_Desc, 
			Old_Value, 
			Old_Value_Desc, 
			New_Value, 
			New_Value_Desc, 
			Emp_ID, 
			Date_Modified
			
		)
		
		SELECT	@Table_Name,
				@Primary_Key_ID,
				@Column_Name,
				@Column_Name_Desc,
				CASE WHEN @Old_Value = '::DBNULL::' THEN NULL ELSE @Old_Value END,
				CASE WHEN @Old_Value_Desc = '::DBNULL::' THEN NULL ELSE @Old_Value_Desc END,
				CASE WHEN @New_Value = '::DBNULL::' THEN NULL ELSE @New_Value END,
				CASE WHEN @New_Value_Desc = '::DBNULL::' THEN NULL ELSE @New_Value_Desc END,
				@Emp_ID,
				@Date_Modified


		SET @returnid = SCOPE_IDENTITY()
	END
	
	SELECT @returnid ReturnValue
END



GO
