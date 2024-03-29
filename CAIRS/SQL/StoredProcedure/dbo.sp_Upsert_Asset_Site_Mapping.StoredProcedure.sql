USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Site_Mapping]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Site_Mapping]
	@ID AS INT,
	@Asset_ID AS INT = null,
	@Site_ID AS INT,
	@Added_By_Emp_ID AS VARCHAR(11),
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
			--Tag ID
			DECLARE @SITE_ID_OLD_VALUE AS INT = (SELECT Site_ID from Asset_Site_Mapping where ID = @ID)
			DECLARE @SITE_DESC_OLD_VALUE AS VARCHAR(100) = (SELECT isnull(Short_Name, Name) from CT_Site WHERE ID = @SITE_ID_OLD_VALUE)
			DECLARE @New_Site_Desc AS VARCHAR(100) = (SELECT isnull(Short_Name, Name) from CT_Site WHERE ID = @Site_ID)
			DECLARE @Table_Name AS VARCHAR(100) = 'Asset_Site_Mapping'
			DECLARE @OLD_Asset_ID AS INT = (SELECT Asset_ID from Asset_Site_Mapping where ID = @ID)

			IF @Site_ID <> @SITE_ID_OLD_VALUE
				BEGIN
					--insert audit log
					EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Site_ID', 'Site ID', @SITE_ID_OLD_VALUE, @SITE_DESC_OLD_VALUE, @Site_ID, @New_Site_Desc, @Added_By_Emp_ID, @Date_Added
			
					--update new site
					UPDATE dbo.Asset_Site_Mapping
					SET
						Site_ID = @Site_ID

					WHERE ID = @ID

					--unassign from bin once a transfer has occured
					EXEC dbo.sp_Assign_Asset_To_Bin '::DBNULL::', @OLD_Asset_ID,  @Added_By_Emp_ID, @Date_Added
				END

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
