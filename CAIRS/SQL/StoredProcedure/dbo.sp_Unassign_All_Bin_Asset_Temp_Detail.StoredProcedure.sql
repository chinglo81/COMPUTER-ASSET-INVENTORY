USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Unassign_All_Bin_Asset_Temp_Detail]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Unassign_All_Bin_Asset_Temp_Detail]
	@HeaderID AS INT
AS
BEGIN
		IF EXISTS (Select 1 from dbo.Asset_Temp_Detail where Asset_Temp_Header_ID = @HeaderID)
			BEGIN
				UPDATE dbo.Asset_Temp_Detail
					set Bin_ID = null
				WHERE Asset_Temp_Header_ID = @HeaderID
			END
END



GO
