USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Update_Asset_Repair_Received]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Create date: 1/17/2017 8:26:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Update_Asset_Repair_Received]
	@ID AS INT, 
	@Received_Disposition_ID AS INT,
	@Received_By_Emp_ID AS VARCHAR(11)
AS
BEGIN
		IF EXISTS (Select 1 from dbo.Asset_Repair where ID = @ID)
			BEGIN
				UPDATE dbo.Asset_Repair

					SET Date_Received = GETDATE(),
						Received_Disposition_ID = @Received_Disposition_ID,
						Received_By_Emp_ID = @Received_By_Emp_ID,
						Date_Modified = GETDATE(),
						Modified_By_Emp_ID = @Received_By_Emp_ID

				WHERE ID = @ID
			END
END





GO
