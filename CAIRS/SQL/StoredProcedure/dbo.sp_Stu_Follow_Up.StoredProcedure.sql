USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Stu_Follow_Up]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Create date: 05/14/2017 10:56:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Stu_Follow_Up]
	@Asset_Student_Transaction_ID AS INT,
	@Is_Asset_Belong_To_Student AS VARCHAR(30) = null,
	@New_Tag_ID AS VARCHAR(100) = null,
	@Disposition_ID AS INT = null,
	@Condition_ID AS INT = null,
	@Bin_ID AS INT = null,
	@Comments AS VARCHAR(MAX) = null,
	@Attachments AS XML,
	@Stu_Responsible_For_Damage AS VARCHAR(30) = null,
	@Emp_ID AS VARCHAR(11),
	@Date AS DateTime
AS
BEGIN
	DECLARE @Asset_ID AS INT = (SELECT Asset_ID From Asset_Student_Transaction WHERE ID = @Asset_Student_Transaction_ID)
	DECLARE @Student_ID AS VARCHAR(20) = (SELECT Student_ID from Asset_Student_Transaction WHERE ID = @Asset_Student_Transaction_ID)
	DECLARE @Student_Name as VARCHAR(100)= (SELECT Datawarehouse.dbo.getStudentNameById(@Student_ID)) 
	DECLARE @Check_In_Type INT = 1 --Standard
	DECLARE @Follow_Up_Disposition_ID INT = (SELECT Asset_Disposition_ID FROM Asset WHERE ID = @Asset_ID)
	DECLARE @Check_In_Disposition_ID INT = @Disposition_ID --Default to paramter
	DECLARE @Check_In_Condition_ID INT = @Condition_ID --Default to parameter

	--Unidentified and asset does not belong to the student
	IF @Follow_Up_Disposition_ID = 17 AND @Is_Asset_Belong_To_Student = '0'
		BEGIN
			SET @Check_In_Type = 2 --Lost
			SET @Check_In_Disposition_ID = 4 --Lost
			SET @Check_In_Condition_ID = null
			SET @Bin_ID = null

			DECLARE @New_Comment AS VARCHAR(MAX)
			SET @New_Comment = 'Student: ' + @Student_ID + ' ' + @Student_Name + ' reported unidentified asset that does not belong to him/her.'

			EXEC dbo.sp_Upsert_Asset_Comment	-1, 
												@Asset_ID, 
												@New_Comment,
												@Emp_ID, 
												@Date,
												null,
												null
		END

	--Interaction followup for unidentified
	IF @Follow_Up_Disposition_ID = 17
		BEGIN
			DECLARE @InteractionComment AS VARCHAR(1000)

			SET @InteractionComment = 'The asset does not belong to the student.'
			IF  @Is_Asset_Belong_To_Student = '0'
				BEGIN
					SET @InteractionComment = 'The asset belongs to the student.'
				END

			--Insert Student Transaction
			EXEC sp_Upsert_Asset_Student_Transaction_Interaction -1,
																 @Asset_Student_Transaction_ID,
																 '1', --Unidentified Interaction 
																 @InteractionComment,
																 @Emp_ID,
																 @Date,
																 null,
																 null,
																 null
		END
	
	EXEC dbo.sp_Stu_Check_In	@Asset_Student_Transaction_ID,
								@Check_In_Type, --Check In Type
								@Check_In_Disposition_ID,
								'0', --Is Police Report Provided
								@Check_In_Condition_ID,
								@Bin_ID, 
								@Comments,
								@Attachments, --Attachments
								@Stu_Responsible_For_Damage,
								@Emp_ID, --Emp_ID
								@Date --Date
	
	IF @New_Tag_ID IS NOT NULL
		BEGIN
			DECLARE @OLD_TAG_ID AS VARCHAR(100) = (SELECT Tag_ID From Asset where ID = @Asset_ID)

			--Update Asset Audit
			EXEC dbo.sp_Insert_Audit_Log  'Asset', 
											@Asset_ID, 
											'Tag_ID', 
											'Tag ID', 
											@OLD_TAG_ID, 
											@OLD_TAG_ID, 
											@New_Tag_ID, 
											@New_Tag_ID, 
											@Emp_ID, 
											@Date

			--Update Asset
			Update Asset
				SET 
					Tag_ID = @New_Tag_ID
			WHERE ID = @Asset_ID
		END

END







GO
