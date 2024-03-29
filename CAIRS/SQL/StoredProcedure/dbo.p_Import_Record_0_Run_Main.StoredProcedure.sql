USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Import_Record_0_Run_Main]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Import_Record_0_Run_Main] AS

	
DECLARE @TodayDate AS DATETIME = getdate()

EXEC dbo.p_Import_Record_1_Validate @TodayDate

EXEC dbo.p_Import_Record_2_Student_Device_Coverage @TodayDate

EXEC dbo.p_Import_Record_3_Device_Payments @TodayDate

EXEC dbo.p_Import_Record_4_Update_Count @TodayDate

EXEC dbo.p_Import_Record_99_End


GO
