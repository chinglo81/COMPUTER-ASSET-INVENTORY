USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Search]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/21/2017 8:37:36 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Search]
	@ID AS INT,
	@Filter_Value AS VARCHAR(4000) = null,
	@Filter_Text AS VARCHAR(4000) = null,
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30) = null,
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
			INSERT INTO dbo.Asset_Search
			(
				Filter_Value,
				Filter_Text,
				Added_By_Emp_ID,
				Date_Added
			)
			SELECT 
				CASE WHEN @Filter_Value = '::DBNULL::' THEN NULL ELSE @Filter_Value END,
				CASE WHEN @Filter_Text = '::DBNULL::' THEN NULL ELSE @Filter_Text END,
				@Added_By_Emp_ID,
				CASE WHEN @Date_Added = '::DBNULL::' THEN NULL ELSE @Date_Added END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Search where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Search
			SET
				Filter_Value = CASE WHEN @Filter_Value = '::DBNULL::' THEN NULL WHEN @Filter_Value IS NULL THEN Filter_Value ELSE @Filter_Value END,
				Filter_Text = CASE WHEN @Filter_Text = '::DBNULL::' THEN NULL WHEN @Filter_Text IS NULL THEN Filter_Text ELSE @Filter_Text END,
				Modified_By_Emp_ID = CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Modified_By_Emp_ID IS NULL THEN Modified_By_Emp_ID ELSE @Modified_By_Emp_ID END,
				Date_Modified = CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL WHEN @Date_Modified IS NULL THEN Date_Modified ELSE @Date_Modified END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
