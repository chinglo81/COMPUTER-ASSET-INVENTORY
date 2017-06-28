USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Delete_Asset_Attachment]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Delete_Asset_Attachment]
	@ID AS INT
AS
BEGIN
		IF EXISTS (Select 1 from dbo.Asset_Attachment where ID = @ID)
			BEGIN
				DELETE FROM dbo.Asset_Attachment
				WHERE ID = @ID
			END
END




GO
