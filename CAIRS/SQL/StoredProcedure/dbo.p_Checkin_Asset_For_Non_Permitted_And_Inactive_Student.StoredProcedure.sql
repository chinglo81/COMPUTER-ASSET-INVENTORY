USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Checkin_Asset_For_Non_Permitted_And_Inactive_Student]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Checkin_Asset_For_Non_Permitted_And_Inactive_Student] AS

	DECLARE @Cursor CURSOR
	DECLARE @EmpID VARCHAR(100) = 'SYSTEM' --Set to system
	DECLARE @Today DATETIME = GETDATE()
	DECLARE @Asset_Student_Transaction_ID int
	DECLARE @Check_In_Type_Code VARCHAR(10) = '7' --Not Return
	DECLARE @Disposition_ID INT = 1010 --Not Returned
	DECLARE @Is_Police_Report_Provided VARCHAR(30) = '0' --False
	DECLARE @Check_In_Condition_ID INT = null
	DECLARE @Bin_ID VARCHAR(10) = null 
	DECLARE @Comment VARCHAR(MAX) --will be set to the Non Permitted Reason
	DECLARE @Attachment XML = null
	DECLARE @Stu_Responsible_For_Damage VARCHAR(1) = '1' --Yes
	DECLARE @Student_ID VARCHAR(20)
	DECLARE @HasRecord VARCHAR(1) = '0'

	--Use for column values
	SET @Cursor = CURSOR FAST_FORWARD 
	FOR 
		Select
			v.Asset_Student_Transaction_ID,
			'Asset not returned. Reason: ' + v.Reason as Comment
		from v_Non_Permitted_And_Inactive_Student_With_Asset v

	OPEN @Cursor 
	FETCH NEXT FROM @Cursor 
	
	INTO @Asset_Student_Transaction_ID, @Comment

	WHILE @@FETCH_STATUS = 0 
		BEGIN 
			SET @HasRecord = '1'

			EXEC dbo.sp_Stu_Check_In	@Asset_Student_Transaction_ID,
										@Check_In_Type_Code,
										@Disposition_ID,
										@Is_Police_Report_Provided,
										@Check_In_Condition_ID,
										@Bin_ID,
										@Comment,
										@Attachment,
										@Stu_Responsible_For_Damage,
										@EmpID,
										@Today

			FETCH NEXT FROM @Cursor
	
			INTO @Asset_Student_Transaction_ID, @Comment

		END

		IF @HasRecord = '1' 
			BEGIN
				EXEC dbo.p_Non_Permitted_And_Inactive_Notification @Today
			END


GO
