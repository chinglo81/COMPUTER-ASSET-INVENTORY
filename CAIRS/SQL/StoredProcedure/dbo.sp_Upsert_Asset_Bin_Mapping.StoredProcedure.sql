USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Bin_Mapping]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Bin_Mapping]
	@ID AS INT,
	@Bin_ID AS INT,
	@Asset_ID AS INT,
	@Date_Added AS VARCHAR(30) = null,
	@Added_By_Emp_ID AS VARCHAR(11) 
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Bin_Mapping
			(
				Bin_ID,
				Asset_ID,
				Date_Added,
				Added_By_Emp_ID
			)
			SELECT 
				@Bin_ID,
				@Asset_ID,
				CASE WHEN @Date_Added = '::DBNULL::' THEN NULL ELSE @Date_Added END,
				@Added_By_Emp_ID

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Bin_Mapping where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Bin_Mapping
			SET
				Bin_ID = @Bin_ID,
				Asset_ID = @Asset_ID

			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
