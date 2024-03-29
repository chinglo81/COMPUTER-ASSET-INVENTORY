USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Assign_Asset_To_Bin]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Assign_Asset_To_Bin]
	@Bin_ID AS VARCHAR(10),
	@Asset_ID AS INT,
	@Emp_ID AS VARCHAR(11),
	@Date AS VARCHAR(30)
AS
BEGIN
	-- Return Value
	DECLARE @AssetBinMapping int
	DECLARE @Bin_Site_ID INT
	DECLARE @Asset_Site_ID INT

	SET @AssetBinMapping = ISNULL((select ID from Asset_Bin_Mapping where Asset_ID = @Asset_ID), -1)
	SET @Bin_Site_ID = ISNULL((SELECT Site_ID from Bin where cast(ID as varchar(100)) = @Bin_ID), -1)
	SET @Asset_Site_ID = ISNULL((SELECT Site_ID from Asset_Site_Mapping where Asset_ID = @Asset_ID), -1)


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 

	--Mapping does not exist.
	IF @AssetBinMapping = -1 
		BEGIN
			--Only create an instance if a bin_id is passed
			INSERT INTO Asset_Bin_Mapping 
			SELECT 
				CASE WHEN @Bin_ID = '::DBNULL::' THEN NULL ELSE @Bin_ID END,
				@Asset_ID,
				@Date,
				@Emp_ID

			SET @AssetBinMapping = SCOPE_IDENTITY()

		END 
	ELSE
		BEGIN
			DECLARE @OLD_BIN as varchar(10)
			DECLARE @OLD_BIN_DESC as varchar(1000)
			DECLARE @NEW_BIN_DESC as varchar(1000)

			SET @OLD_BIN = (select Bin_ID from Asset_Bin_Mapping where ID = @AssetBinMapping);
			SET @OLD_BIN_DESC = (select 
									cast(b.ID as varchar(10)) + ' - ' + s.Name + ' Bin #:' + cast(b.Number as varchar(10)) as SiteBinDesc
								from Bin b
								inner join CT_Site s
									on s.ID = b.Site_ID
								where b.ID = @OLD_BIN)

			SET @NEW_BIN_DESC = (select 
									cast(b.ID as varchar(10)) + ' - ' + s.Name + ' Bin #:' + cast(b.Number as varchar(10)) as SiteBinDesc
								from Bin b
								inner join CT_Site s
									on s.ID = b.Site_ID
								where cast(b.ID as varchar(100)) = @Bin_ID)
			

			IF @Bin_ID <> ISNULL(@OLD_BIN, '::DBNULL::')
			BEGIN
				EXEC dbo.sp_Insert_Audit_Log 'Asset_Bin_Mapping', @AssetBinMapping, 'Bin_ID', 'Bin ID', @OLD_BIN, @OLD_BIN_DESC, @Bin_ID, @NEW_BIN_DESC, @Emp_ID, @Date
			
				UPDATE Asset_Bin_Mapping
				SET
					Bin_ID = CASE WHEN @Bin_ID = '::DBNULL::' THEN NULL ELSE @Bin_ID END
				WHERE ID = @AssetBinMapping;
			END

		END




	--Create Asset Site Stored Mapping for site mismatch for asset and bin
	DECLARE @Asset_Site_Stored_Mapping_ID INT
	SET @Asset_Site_Stored_Mapping_ID = ISNULL((SELECT ID FROM Asset_Site_Stored_Mapping WHERE Asset_ID = @Asset_ID), -1)
	
	IF @Bin_Site_ID <> @Asset_Site_ID
		BEGIN
			--Check to see if there is one that already exist
			IF @Asset_Site_Stored_Mapping_ID = -1 
				BEGIN
					INSERT INTO Asset_Site_Stored_Mapping 
					SELECT @Asset_ID, @Asset_Site_ID, @Bin_Site_ID, @Emp_ID, @Date
				END
			ELSE
				BEGIN
					UPDATE Asset_Site_Stored_Mapping
						SET 
							Asset_Site_ID = @Asset_Site_ID,
							Stored_Site_ID = @Bin_Site_ID,
							Emp_ID = @Emp_ID,
							Date_Modified = @Date
					WHERE ID = @Asset_Site_Stored_Mapping_ID
				END

		END
	--Remove Stored Mapping once the asset is back at the site it belongs to
	IF @Bin_Site_ID = @Asset_Site_ID AND @Asset_Site_Stored_Mapping_ID <> -1 
		BEGIN
			UPDATE Asset_Site_Stored_Mapping
				SET 
					Stored_Site_ID = null,
					Emp_ID = @Emp_ID,
					Date_Modified = @Date
			WHERE ID = @Asset_Site_Stored_Mapping_ID
		END


	SELECT @AssetBinMapping as ReturnValue
END






GO
