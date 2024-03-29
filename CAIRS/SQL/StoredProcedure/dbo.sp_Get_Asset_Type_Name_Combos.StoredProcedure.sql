USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_Asset_Type_Name_Combos]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Josh Pohl
-- Create date: 10/02/2017
-- Update date:	10/04/2017
-- Update by:	Josh Pohl
-- Description:	Stored Procedure for getting Asset Type Description Combos (ex. "Laptop (HP X360 310 G2)")
-- =============================================
CREATE PROCEDURE [dbo].[sp_Get_Asset_Type_Name_Combos]
@Asset_Base_Type_List AS VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Temp table to hold base types to filter by
	DECLARE @Tbl_Asset_Base_Types AS Table (
		Asset_Base_Type INT
	)
	-- Insert paramters into temp tables
	INSERT INTO @Tbl_Asset_Base_Types
	SELECT * FROM dbo.CSVToTable(@Asset_Base_Type_List, ',')
	
	SELECT abt.Name + ' (' + at.Name + ')' AS Asset_Type_Combo
		, at.ID AS AssetTypeID
	FROM Asset_Tracking.dbo.CT_Asset_Base_Type abt
		INNER JOIN Asset_Tracking.dbo.CT_Asset_Type at ON at.Asset_Base_Type_ID = abt.ID
	WHERE abt.ID IN (SELECT * FROM @Tbl_Asset_Base_Types)
	ORDER BY Asset_Type_Combo
END

GO
