USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Delete_Asset_Temp_Detail]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Delete_Asset_Temp_Detail]
	@ID AS INT
AS
BEGIN
		IF EXISTS (Select 1 from dbo.Asset_Temp_Detail where ID = @ID)
			BEGIN
				DELETE FROM dbo.Asset_Temp_Detail
				WHERE ID = @ID
			END
END



GO
