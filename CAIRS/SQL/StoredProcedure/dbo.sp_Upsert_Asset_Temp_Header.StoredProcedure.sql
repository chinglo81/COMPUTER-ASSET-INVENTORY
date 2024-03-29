USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Temp_Header]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Temp_Header]
	@ID AS INT,
	@Asset_Site_ID AS INT,
	@Name AS VARCHAR(100) = null,
	@Description AS VARCHAR(1000) = null,
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30),
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null,
	@Has_Submit AS VARCHAR(30) = null,
	@Date_Submit AS VARCHAR(30) = null,
	@Submitted_By_Emp_ID AS VARCHAR(11) = null
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Temp_Header
			(
				Asset_Site_ID,
				Name,
				Description,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified,
				Has_Submit,
				Date_Submit,
				Submitted_By_Emp_ID
			)
			SELECT 
				@Asset_Site_ID,
				CASE WHEN @Name = '::DBNULL::' THEN NULL ELSE @Name END,
				CASE WHEN @Description = '::DBNULL::' THEN NULL ELSE @Description END,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END,
				CASE WHEN @Has_Submit = '::DBNULL::' THEN NULL ELSE @Has_Submit END,
				CASE WHEN @Date_Submit = '::DBNULL::' THEN NULL ELSE @Date_Submit END,
				CASE WHEN @Submitted_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Submitted_By_Emp_ID END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Temp_Header where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Temp_Header
			SET
				Asset_Site_ID = @Asset_Site_ID,
				Name = CASE WHEN @Name = '::DBNULL::' THEN NULL WHEN @Name IS NULL THEN Name ELSE @Name END,
				Description = CASE WHEN @Description = '::DBNULL::' THEN NULL WHEN @Description IS NULL THEN Description ELSE @Description END,
				Modified_By_Emp_ID = CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Modified_By_Emp_ID IS NULL THEN Modified_By_Emp_ID ELSE @Modified_By_Emp_ID END,
				Date_Modified = CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL WHEN @Date_Modified IS NULL THEN Date_Modified ELSE @Date_Modified END,
				Has_Submit = CASE WHEN @Has_Submit = '::DBNULL::' THEN NULL WHEN @Has_Submit IS NULL THEN Has_Submit ELSE @Has_Submit END,
				Date_Submit = CASE WHEN @Date_Submit = '::DBNULL::' THEN NULL WHEN @Date_Submit IS NULL THEN Date_Submit ELSE @Date_Submit END,
				Submitted_By_Emp_ID = CASE WHEN @Submitted_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Submitted_By_Emp_ID IS NULL THEN Submitted_By_Emp_ID ELSE @Submitted_By_Emp_ID END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
