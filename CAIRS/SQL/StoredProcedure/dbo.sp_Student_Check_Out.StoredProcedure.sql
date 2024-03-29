USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Student_Check_Out]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Create date: 02/13/2017 06:20:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Student_Check_Out]
	@Student_ID AS VARCHAR(20), 
	@Tag_ID AS VARCHAR(100),
	@Emp_ID AS VARCHAR(11),
	@Date AS DateTime
AS
BEGIN
	DECLARE @Serial_Num AS VARCHAR(100) = (SELECT Serial_Number FROM Asset where Tag_ID = @Tag_ID)
	DECLARE @Message AS VARCHAR(100)
	DECLARE @Validation_TBL AS TABLE(
		ErrorMesage VARCHAR(1000)
	)
	--Check validation
	INSERT INTO @Validation_TBL EXEC dbo.sp_Validate_Student_CheckOut @Student_ID, @Tag_ID, @Serial_Num

	--
	IF NOT EXISTS(SELECT 1 FROM @Validation_TBL)
		BEGIN
			DECLARE @Asset_ID AS INT
			DECLARE @Student_School_Number AS VARCHAR(3)
			DECLARE @School_Year AS INT
			DECLARE @Check_Out_Asset_Condition_ID AS INT
			DECLARE @Disposition_Check_Out AS INT
			DECLARE @Dispoistion_Check_Out_Desc AS VARCHAR(100)
			DECLARE @Old_Disposition_ID AS INT
			DECLARE @Old_Disposition_Desc AS VARCHAR(100)

			SET @Asset_ID = (SELECT ID FROM Asset WHERE Tag_ID = @Tag_ID and Is_Active = 1)
			SET @Student_School_Number = (SELECT SasiSchoolNum FROM datawarehouse.dbo.Student WHERE StudentId = @Student_ID)
			SET @School_Year = (SELECT mcs.dbo.GetSchoolCCYY(Getdate()))
			SET @Check_Out_Asset_Condition_ID = (SELECT Asset_Condition_ID FROM Asset WHERE ID = @Asset_ID)
			SET @Disposition_Check_Out = (SELECT ID FROM CT_Asset_Disposition WHERE Code = '1') --Get Assigned ID
			SET @Dispoistion_Check_Out_Desc = (SELECT dbo.GetAssetDispositionNameById(@Disposition_Check_Out))
			SET @Old_Disposition_ID = (SELECT Asset_Disposition_ID FROM Asset WHERE ID = @Asset_ID)
			SET @Old_Disposition_Desc = (SELECT dbo.GetAssetDispositionNameById(@Old_Disposition_ID))


			/*
			select
				ID, 
				Asset_Disposition_ID, 
				dbo.GetAssetDispositionNameById(Asset_Disposition_ID) AS Asset_Disposition_Desc,
				Asset_Condition_ID, 
				dbo.GetAssetConditionNameById(Asset_Condition_ID) AS Asset_Condition_Desc
			from dbo.Asset
			where Tag_ID = @Tag_ID and Is_Active = 1*/



			--Create Student Transaction
			EXEC dbo.sp_Upsert_Asset_Student_Transaction -1, --ID
														  @Asset_ID, --Asset_ID
														  @Student_ID, --Student_ID
														  @Student_School_Number, --Student School
														  @School_Year, --School_year
														  @Check_Out_Asset_Condition_ID, --Check_Out_Asset_Condition_ID 
														  @Emp_ID, --Check_Out_Emp_ID
														  @Date, --Check_Out_Date
														  null, --Check_In_Type_Code
														  null, --Check_In_Asset_Condition_ID
														  null, --Check_In_By_Emp_ID
														  null, --Date_Check_In
														  null, --Comment
														  null, --Check_In_Disposition_ID
														  null, --Found_Date
														  null, --Found_Disposition
														  null, --Found_Asset_Condition_ID,
														  null, --Stu_Responsible_Damage
														  null --Return ID

			--Update Asset Audit
			--Disposition
			EXEC dbo.sp_Insert_Audit_Log  'Asset', 
										  @Asset_ID, 
										  'Asset_Disposition_ID', 
										  'Disposition', 
										  @Old_Disposition_ID, 
										  @Old_Disposition_Desc, 
										  @Disposition_Check_Out, 
										  @Dispoistion_Check_Out_Desc, 
										  @Emp_ID, 
										  @Date
			
			--Update Asset
			Update Asset
				SET 
					Asset_Disposition_ID = @Disposition_Check_Out
			WHERE ID = @Asset_ID

			--Remove from bin if Exist
			IF EXISTS (SELECT 1 from Asset_Bin_Mapping where Asset_ID = @Asset_ID)
				BEGIN
					EXEC dbo.sp_Assign_Asset_To_Bin '::DBNULL::', @Asset_ID, @Emp_ID, @Date
				END


			SET @Message = 'Sucessfully assigned asset to student.'
		END
	ELSE
		BEGIN
			SET @Message = 'Validation error checking out asset to student. Please send email programmersupport for support.'
		END

	--SELECT @Message AS Msg
	SELECT * FROM @Validation_TBL

END






GO
