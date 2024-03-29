USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Comment]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/27/2017 2:30:51 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Comment]
	@ID AS INT,
	@Asset_ID AS INT,
	@Comment AS VARCHAR(max) = null,
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30),
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Comment
			(
				Asset_ID,
				Comment,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_ID,
				CASE WHEN @Comment = '::DBNULL::' THEN NULL ELSE @Comment END,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Comment where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Comment
			SET
				Asset_ID = CASE WHEN @Asset_ID IS NULL THEN Asset_ID ELSE @Asset_ID END,
				Comment = CASE WHEN @Comment = '::DBNULL::' THEN NULL WHEN @Comment IS NULL THEN Comment ELSE @Comment END,
				Modified_By_Emp_ID = @Modified_By_Emp_ID,
				Date_Modified = @Date_Modified
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
