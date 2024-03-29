USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Update_Asset_Search_Detail_Check]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Update_Asset_Search_Detail_Check]
	@Asset_Search_ID AS INT,
	@Asset_ID as int,
	@Is_Checked as Varchar(1)
AS
	IF @Asset_ID = -1 
		BEGIN 
			UPDATE dbo.Asset_Search_Detail
				SET Is_Checked = @Is_Checked
			WHERE Asset_Search_ID = @Asset_Search_ID
		END
	ELSE
		IF EXISTS (Select 1 from dbo.Asset_Search_Detail where Asset_Search_ID = @Asset_Search_ID and Asset_ID = @Asset_ID)
			BEGIN
				UPDATE dbo.Asset_Search_Detail
					SET Is_Checked = @Is_Checked
				WHERE Asset_Search_ID = @Asset_Search_ID
				AND Asset_ID = @Asset_ID
			END
		



GO
