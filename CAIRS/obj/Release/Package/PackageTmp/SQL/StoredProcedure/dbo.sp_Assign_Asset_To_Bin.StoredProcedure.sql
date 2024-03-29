USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Assign_Asset_To_Bin]    Script Date: 2/3/2017 10:35:31 AM ******/
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
	
	SET @AssetBinMapping = ISNULL((select ID from Asset_Bin_Mapping where Asset_ID = @Asset_ID), -1)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 

	--Mapping does not exist.
	IF @AssetBinMapping = -1 
		BEGIN
			INSERT INTO Asset_Bin_Mapping 
			SELECT 
				@Bin_ID,
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

	SELECT @AssetBinMapping as ReturnValue
END






GO
