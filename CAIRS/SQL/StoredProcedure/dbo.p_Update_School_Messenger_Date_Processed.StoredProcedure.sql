USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Update_School_Messenger_Date_Processed]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Lo, Ching
-- Create date: 6/29/2017
-- Description:	Create Excel Worksheet to be store in a folder path
-- =============================================
CREATE PROCEDURE [dbo].[p_Update_School_Messenger_Date_Processed] 
	-- Add the parameters for the stored procedure here
	AS
	UPDATE Asset_Student_Fee
	SET 
		Date_Processed_School_Msg = GETDATE(),
		Is_Student_Active_When_Processed_Fee = CASE when (select StudentStatus from Datawarehouse.dbo.Student where StudentId = Student_ID) is null then 1 else 0 end
	WHERE 1=1
		and Date_Processed_School_Msg is null
		and Is_Active = 1


GO
