USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Site_Mapping]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Site_Mapping]
	@ID AS INT,
	@Asset_ID AS INT,
	@Site_ID AS INT,
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30)
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Site_Mapping
			(
				Asset_ID,
				Site_ID,
				Added_By_Emp_ID,
				Date_Added
			)
			SELECT 
				@Asset_ID,
				@Site_ID,
				@Added_By_Emp_ID,
				@Date_Added

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Site_Mapping where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Site_Mapping
			SET
				Asset_ID = @Asset_ID,
				Site_ID = @Site_ID

			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
