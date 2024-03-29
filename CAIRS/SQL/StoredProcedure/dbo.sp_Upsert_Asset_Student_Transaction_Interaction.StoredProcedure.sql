USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Student_Transaction_Interaction]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 2/20/2017 11:28:33 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Student_Transaction_Interaction]
	@ID AS INT,
	@Asset_Student_Transaction_ID AS INT,
	@Interaction_Type_ID AS INT,
	@Comment AS VARCHAR(1000) = null,
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30),
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null,
	@returnid INT = null OUTPUT 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Student_Transaction_Interaction
			(
				Asset_Student_Transaction_ID,
				Interaction_Type_ID,
				Comment,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_Student_Transaction_ID,
				@Interaction_Type_ID,
				CASE WHEN @Comment = '::DBNULL::' THEN NULL ELSE @Comment END,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Student_Transaction_Interaction where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Student_Transaction_Interaction
			SET
				Asset_Student_Transaction_ID = CASE WHEN @Asset_Student_Transaction_ID IS NULL THEN Asset_Student_Transaction_ID ELSE @Asset_Student_Transaction_ID END,
				Interaction_Type_ID = CASE WHEN @Interaction_Type_ID IS NULL THEN Interaction_Type_ID ELSE @Interaction_Type_ID END,
				Comment = CASE WHEN @Comment = '::DBNULL::' THEN NULL WHEN @Comment IS NULL THEN Comment ELSE @Comment END,
				Modified_By_Emp_ID = @Modified_By_Emp_ID,
				Date_Modified = @Date_Modified
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
