USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Update_Asset_Search_Detail_Check]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Update_Asset_Search_Detail_Check]
	@Asset_Search_ID AS INT,
	@Asset_ID VARCHAR(max),
	@Is_Checked as Varchar(1)
AS
	IF @Asset_ID = '-1' 
		BEGIN 
			UPDATE dbo.Asset_Search_Detail
				SET Is_Checked = @Is_Checked
			WHERE Asset_Search_ID = @Asset_Search_ID
		END
	ELSE
		IF EXISTS (
					Select 1 
					from dbo.Asset_Search_Detail 
					where Asset_Search_ID = @Asset_Search_ID 
					and Asset_ID in (select * from dbo.CSVToTable(@Asset_ID,','))
		)
			BEGIN
				UPDATE dbo.Asset_Search_Detail
					SET Is_Checked = @Is_Checked
				WHERE 1=1
					AND Asset_Search_ID = @Asset_Search_ID
					AND Asset_ID in (select * from dbo.CSVToTable(@Asset_ID,','))
			END
		



GO
