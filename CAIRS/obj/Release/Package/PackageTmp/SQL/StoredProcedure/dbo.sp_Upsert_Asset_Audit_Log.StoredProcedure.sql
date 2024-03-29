USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Audit_Log]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Audit_Log]
	@ID AS INT,
	@Asset_ID AS INT,
	@Column_Name AS VARCHAR(100) ,
	@Old_Value AS VARCHAR(1000) = null,
	@New_Value AS VARCHAR(1000) = null,
	@Emp_ID AS VARCHAR(11) ,
	@Date_Modified AS VARCHAR(30)
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Audit_Log
			(
				Asset_ID,
				Column_Name,
				Old_Value,
				New_Value,
				Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_ID,
				@Column_Name,
				CASE WHEN @Old_Value = '::DBNULL::' THEN NULL ELSE @Old_Value END,
				CASE WHEN @New_Value = '::DBNULL::' THEN NULL ELSE @New_Value END,
				@Emp_ID,
				@Date_Modified

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Audit_Log where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Audit_Log
			SET
				Asset_ID = @Asset_ID,
				Column_Name = @Column_Name,
				Old_Value = CASE WHEN @Old_Value = '::DBNULL::' THEN NULL WHEN @Old_Value IS NULL THEN Old_Value ELSE @Old_Value END,
				New_Value = CASE WHEN @New_Value = '::DBNULL::' THEN NULL WHEN @New_Value IS NULL THEN New_Value ELSE @New_Value END,
				Emp_ID = @Emp_ID,
				Date_Modified = @Date_Modified
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
