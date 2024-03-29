USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Attachment]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/27/2017 2:51:26 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Attachment]
	@ID AS INT,
	@Asset_ID AS INT,
	@Student_ID AS VARCHAR(20) = null,
	@File_Type_ID AS INT,
	@Name AS VARCHAR(100) ,
	@Description AS VARCHAR(1000) = null,
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
			INSERT INTO dbo.Asset_Attachment
			(
				Asset_ID,
				Student_ID,
				File_Type_ID,
				Name,
				Description,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_ID,
				CASE WHEN @Student_ID = '::DBNULL::' THEN NULL ELSE @Student_ID END,
				@File_Type_ID,
				@Name,
				CASE WHEN @Description = '::DBNULL::' THEN NULL ELSE @Description END,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Attachment where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Attachment
			SET
				Student_ID = CASE WHEN @Student_ID = '::DBNULL::' THEN NULL WHEN @Student_ID IS NULL THEN Student_ID ELSE @Student_ID END,
				File_Type_ID = CASE WHEN @File_Type_ID IS NULL THEN File_Type_ID ELSE @File_Type_ID END,
				Name = CASE WHEN @Name IS NULL THEN Name ELSE @Name END,
				Description = CASE WHEN @Description = '::DBNULL::' THEN NULL WHEN @Description IS NULL THEN Description ELSE @Description END,
				Modified_By_Emp_ID = CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Modified_By_Emp_ID IS NULL THEN Modified_By_Emp_ID ELSE @Modified_By_Emp_ID END,
				Date_Modified = CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL WHEN @Date_Modified IS NULL THEN Date_Modified ELSE @Date_Modified END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
