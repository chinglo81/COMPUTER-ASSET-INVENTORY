USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Delete_Asset_Repair]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Delete_Asset_Repair]
	@ID AS INT
AS
BEGIN
		IF EXISTS (Select 1 from dbo.Asset_Repair where ID = @ID)
			BEGIN
				DELETE FROM dbo.Asset_Repair
				WHERE ID = @ID
			END
END




GO
