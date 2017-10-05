USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Update_Asset_Repair_Received]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Update_Asset_Repair_Received]
	@ID AS INT, 
	@Received_By_Emp_ID AS VARCHAR(11)
AS
BEGIN
		IF EXISTS (Select 1 from dbo.Asset_Repair where ID = @ID)
			BEGIN
				UPDATE dbo.Asset_Repair
					SET Date_Received = GETDATE(),
						Received_By_Emp_ID = @Received_By_Emp_ID

				WHERE ID = @ID
			END
END





GO
