USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Stu_Check_In_Edit]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Create date: 10/3/2017 1:35:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Stu_Check_In_Edit]
	@Asset_Student_Transaction_ID AS INT,
	@Check_In_Type_ID AS INT,
	@Disposition_ID AS INT,
	@Check_In_Condition_ID AS INT = null,
	@Stu_Responsible_For_Damage AS VARCHAR(1) = '0',
	@Is_Police_Report_Provided AS VARCHAR(1) = '0',
	@Comments AS VARCHAR(MAX)= null,
	@Edit_Reason AS VARCHAR(MAX) = null,
	@Emp_ID AS VARCHAR(11),
	@Date AS DateTime
AS
BEGIN
	--Asset Student Transaction for processs
	DECLARE @Tbl_Asset_Student_Transaction_Process as TABLE(
		Asset_Student_Transaction_ID INT,
		--Old Values
		Old_Check_In_Type_ID int,
		Old_Check_In_Type_Desc varchar(100),
		Old_Check_In_Disposition_ID int,
		Old_Check_In_Disposition_Desc varchar(100),
		Old_Check_In_Condition_ID int,
		Old_Check_In_Condition_Desc varchar(100),
		Old_Stu_Responsible_For_Damage varchar(1),
		Old_Stu_Responsible_For_Damage_Desc varchar(3),
		Old_Is_Police_Report_Provided varchar(1),
		Old_Is_Police_Report_Provided_Desc varchar(3),
		Old_Comment VARCHAR(MAX),
		--New Values
		New_Check_In_Type_ID INT,
		New_Check_In_Type_Desc varchar(100),
		New_Check_In_Disposition_ID int,
		New_Check_In_Disposition_Desc varchar(100),
		New_Check_In_Condition_ID int,
		New_Check_In_Condition_Desc varchar(100),
		New_Stu_Responsible_For_Damage varchar(1),
		New_Stu_Responsible_For_Damage_Desc varchar(3),
		New_Is_Police_Report_Provided varchar(1),
		New_Is_Police_Report_Provided_Desc varchar(3),
		New_Comment VARCHAR(MAX)
	)
	--insert records into temp tbl
	INSERT INTO @Tbl_Asset_Student_Transaction_Process
	SELECT
		ast.ID,
		--Old Value
		ast.Check_In_Type_ID,
		ast.Check_In_Type_Desc,
		ast.Check_In_Disposition_ID,
		ast.Check_In_Disposition_Desc,
		ast.Check_In_Asset_Condition_ID,
		ast.Check_In_Asset_Condition_Desc,
		ast.Stu_Responsible_For_Damage,
		case when ast.Stu_Responsible_For_Damage = 1 then 'Yes' else 'No' end as Stu_Responsible_For_Damage_Desc,
		ast.Is_Police_Report_Provided,
		case when ast.Is_Police_Report_Provided = 1 then 'Yes' else 'No' end as Is_Police_Report_Provided,
		ast.Asset_Student_Fee_Comment as Comment,

		--New Value
		@Check_In_Type_ID as New_Check_In_Type_ID,
		dbo.GetCheckInTypeNameById(@Check_In_Type_ID) as New_Check_In_Type_Desc,
		@Disposition_ID as New_Check_In_Disposition,
		dbo.GetAssetDispositionNameById(@Disposition_ID) as New_Check_In_Disposition,
		@Check_In_Condition_ID,
		dbo.GetAssetConditionNameById(@Check_In_Condition_ID),
		@Stu_Responsible_For_Damage as New_Stu_Responsible_For_Damage,
		case when @Stu_Responsible_For_Damage = '1' then 'Yes' else 'No' end as Stu_Responsible_For_Damage_Desc,
		@Is_Police_Report_Provided as New_Is_Police_Report_Provided,
		case when @Is_Police_Report_Provided = '1' then 'Yes' else 'No' end as Is_Police_Report_Provided_Desc,
		@Comments as New_Comment

	FROM v_Asset_Student_Assignment ast
	where ast.ID = @Asset_Student_Transaction_ID

	
	IF	EXISTS (--Check to see if the record exist and we have some changes
				SELECT 1 
				FROM @Tbl_Asset_Student_Transaction_Process a
				WHERE a.Old_Check_In_Type_ID <> a.New_Check_In_Type_ID
					OR a.Old_Check_In_Disposition_ID <> a.New_Check_In_Disposition_ID
					OR a.Old_Check_In_Condition_ID <> a.New_Check_In_Condition_ID
					OR a.Old_Stu_Responsible_For_Damage <> a.New_Stu_Responsible_For_Damage
					OR a.Old_Is_Police_Report_Provided <> a.New_Is_Police_Report_Provided
					OR a.Old_Comment <> a.New_Comment
		)
	BEGIN
		--Log Edit
		DECLARE @Change_Log XML = (SELECT * FROM @Tbl_Asset_Student_Transaction_Process FOR XML RAW ('Changes'), ROOT ('Asset_Student_Transaction'), ELEMENTS XSINIL)

		INSERT INTO Asset_Student_Transaction_Edit_Log
		SELECT	@Asset_Student_Transaction_ID, @Edit_Reason, @Change_Log, @Emp_ID, @Date

		
		DECLARE @Asset_Transaction_Tbl_Name AS VARCHAR(100) = 'Asset_Student_Transaction'
		--Old Value
		DECLARE @Old_Chk_In_Type_ID INT = (SELECT v.Old_Check_In_Type_ID from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Chk_In_Type_Desc VARCHAR(100) = (SELECT v.Old_Check_In_Type_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Check_In_Disposition_ID INT = (SELECT v.Old_Check_In_Disposition_ID from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Check_In_Disposition_Desc VARCHAR(100) = (SELECT v.Old_Check_In_Disposition_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Check_In_Condition_ID INT = (SELECT v.Old_Check_In_Condition_ID from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Check_In_Condition_Desc VARCHAR(100) = (SELECT v.Old_Check_In_Condition_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Stu_Responsible_For_Damage VARCHAR(1) = (SELECT v.Old_Stu_Responsible_For_Damage from @Tbl_Asset_Student_Transaction_Process v)
		DECLARE @Old_Stu_Responsible_For_Damage_Desc VARCHAR(3) = (SELECT v.Old_Stu_Responsible_For_Damage_Desc from @Tbl_Asset_Student_Transaction_Process v)
		DECLARE @Old_Is_Police_Report_Provided VARCHAR(1) = (SELECT v.Old_Is_Police_Report_Provided from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Is_Police_Report_Provided_Desc VARCHAR(3) = (SELECT v.Old_Is_Police_Report_Provided_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @Old_Comment VARCHAR(MAX) = (SELECT v.Old_Comment from @Tbl_Asset_Student_Transaction_Process v) 
		--New Value
		DECLARE @New_Chk_In_Type_ID VARCHAR(10) = (SELECT v.New_Check_In_Type_ID from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Chk_In_Type_Desc VARCHAR(100) = (SELECT v.New_Check_In_Type_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Check_In_Disposition_ID INT = (SELECT v.New_Check_In_Disposition_ID from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Check_In_Disposition_Desc VARCHAR(10) = (SELECT v.New_Check_In_Disposition_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Check_In_Condition_ID INT = (SELECT v.New_Check_In_Condition_ID from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Check_In_Condition_Desc VARCHAR(100) = (SELECT v.Old_Check_In_Disposition_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Stu_Responsible_For_Damage VARCHAR(1) = (SELECT v.New_Stu_Responsible_For_Damage from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Stu_Responsible_For_Damage_Desc VARCHAR(3) = (SELECT v.New_Stu_Responsible_For_Damage_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Is_Police_Report_Provided VARCHAR(1) = (SELECT v.New_Is_Police_Report_Provided from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Is_Police_Report_Provided_Desc VARCHAR(3) = (SELECT v.New_Is_Police_Report_Provided_Desc from @Tbl_Asset_Student_Transaction_Process v) 
		DECLARE @New_Comment VARCHAR(MAX) = (SELECT v.New_Comment from @Tbl_Asset_Student_Transaction_Process v) 


		--AUDIT LOGGING
		--Check In Type
		IF @Old_Chk_In_Type_ID <> @New_Chk_In_Type_ID
		BEGIN
			EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
										 @Asset_Student_Transaction_ID, 
										 'Check_In_Type_ID', 
										 'Check-in Type', 
										 @Old_Chk_In_Type_ID, 
										 @Old_Chk_In_Type_Desc, 
										 @New_Chk_In_Type_ID, 
										 @New_Chk_In_Type_Desc, 
										 @Emp_ID, 
										 @Date
		END

		--Check In Disposition
		IF @Old_Check_In_Disposition_ID <> @New_Check_In_Disposition_ID
		BEGIN
			EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
										 @Asset_Student_Transaction_ID, 
										 'Check_In_Disposition', 
										 'Check-in Disposition', 
										 @Old_Check_In_Disposition_ID, 
										 @Old_Check_In_Disposition_Desc, 
										 @New_Check_In_Disposition_ID, 
										 @New_Check_In_Disposition_Desc, 
										 @Emp_ID, 
										 @Date
		END

		--Check In Condition
		IF @Old_Check_In_Condition_ID <> @New_Check_In_Condition_ID
		BEGIN
			EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
										 @Asset_Student_Transaction_ID, 
										 'Check_In_Asset_Condition', 
										 'Check-in Condition', 
										 @Old_Check_In_Condition_ID, 
										 @Old_Check_In_Condition_Desc, 
										 @New_Check_In_Condition_ID, 
										 @New_Check_In_Condition_Desc, 
										 @Emp_ID, 
										 @Date
		END

		--Student Responsible For Damage
		IF @Old_Stu_Responsible_For_Damage <> @New_Stu_Responsible_For_Damage
		BEGIN
			EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
										 @Asset_Student_Transaction_ID, 
										 'Stu_Responsible_For_Damage', 
										 'Student Responsible For Damage', 
										 @Old_Stu_Responsible_For_Damage, 
										 @Old_Stu_Responsible_For_Damage_Desc, 
										 @New_Stu_Responsible_For_Damage, 
										 @New_Stu_Responsible_For_Damage_Desc, 
										 @Emp_ID, 
										 @Date
		END

		--Police Report
		IF @Old_Is_Police_Report_Provided <> @New_Is_Police_Report_Provided
		BEGIN
			EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
										 @Asset_Student_Transaction_ID, 
										 'Is_Police_Report_Provided', 
										 'Is Police Report Provided', 
										 @Old_Is_Police_Report_Provided, 
										 @Old_Is_Police_Report_Provided_Desc, 
										 @New_Is_Police_Report_Provided, 
										 @New_Is_Police_Report_Provided_Desc, 
										 @Emp_ID, 
										 @Date
		END

		--Comment
		IF @Old_Comment <> @New_Comment
		BEGIN
			EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
										 @Asset_Student_Transaction_ID, 
										 'Comment', 
										 'Comment', 
										 @Old_Comment, 
										 @Old_Comment, 
										 @New_Comment, 
										 @New_Comment, 
										 @Emp_ID, 
										 @Date
		END

		--This will force null to update
		DECLARE @Found_Date AS VARCHAR(30) = '::DBNULL::'
		DECLARE @Found_Disposition AS VARCHAR(30) = '::DBNULL::'
		DECLARE @Found_Condition_ID AS VARCHAR(30) = '::DBNULL::'

		IF @New_Chk_In_Type_ID = '4' --FOUND
		BEGIN

			DECLARE @Old_Found_Date AS DATE = (select Found_Date from Asset_Student_Transaction where id = @Asset_Student_Transaction_ID)
			DECLARE @Old_Found_Disposition_ID AS INT = (select Found_Disposition_ID from Asset_Student_Transaction where id = @Asset_Student_Transaction_ID) 
			DECLARE @Old_Found_Disposition_Desc VARCHAR(100) = (select dbo.GetAssetDispositionNameById(@Old_Found_Disposition_ID))
			DECLARE @Old_Found_Condition_ID AS INT = (select Found_Asset_Condition_ID from Asset_Student_Transaction where id = @Asset_Student_Transaction_ID)
			DECLARE @Old_Found_Condition_Desc AS INT = (select dbo.GetAssetConditionNameById(@Old_Found_Condition_ID))

			SET @Found_Date = case when @Old_Found_Date is null then @Date else @Old_Found_Date end --only use found date if the previous one is null
			SET @Found_Disposition = @New_Check_In_Disposition_ID
			SET @Found_Condition_ID = @New_Check_In_Condition_ID 

			--Check In Disposition
			IF @Old_Found_Disposition_ID <> @New_Check_In_Disposition_ID
			BEGIN
				EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
											 @Asset_Student_Transaction_ID, 
											 'Found_Disposition_ID', 
											 'Found Disposition', 
											 @Old_Found_Disposition_ID, 
											 @Old_Found_Disposition_Desc, 
											 @New_Check_In_Disposition_ID, 
											 @New_Check_In_Disposition_Desc, 
											 @Emp_ID, 
											 @Date
			END

			--Check In Condition
			IF @Old_Found_Condition_ID <> @New_Check_In_Condition_ID
			BEGIN
				EXEC dbo.sp_Insert_Audit_Log @Asset_Transaction_Tbl_Name, 
											 @Asset_Student_Transaction_ID, 
											 'Found_Asset_Condition_ID', 
											 'Found Condition', 
											 @Old_Found_Condition_ID, 
											 @Old_Found_Condition_Desc, 
											 @New_Check_In_Condition_ID, 
											 @New_Check_In_Condition_Desc, 
											 @Emp_ID, 
											 @Date
			END


		END

		--Update Asset Student Transaction
		EXEC dbo.sp_Upsert_Asset_Student_Transaction @Asset_Student_Transaction_ID, --ID
													null, --Asset_ID
													null, --Student_ID
													null, --Student_School_Number
													null, --School_Year
													null, --Check_Out_Asset_Condition_ID
													null, --Check_Out_Emp_ID
													null, --Date_Check_out
													@New_Chk_In_Type_ID, --Check_In_Type_Code
													@New_Check_In_Condition_ID, --Check_In_Asset_Condition_ID
													null, --Check_In_Emp_ID
													null, --Check_In_Date
													@New_Comment, --Comments
													@New_Check_In_Disposition_ID, --Check_In_Disposition_ID
													@Found_Date,
													@Found_Disposition,
													@Found_Condition_ID,
													@Stu_Responsible_For_Damage,
													null --Return ID


		--Revert Fees if the following:
		IF	@Old_Chk_In_Type_ID <> @New_Chk_In_Type_ID OR --Check In Type
			@Old_Check_In_Disposition_ID <> @New_Check_In_Disposition_ID OR --Disposition
			@Old_Stu_Responsible_For_Damage <> @New_Stu_Responsible_For_Damage OR --Student Responsible
			@Old_Is_Police_Report_Provided <> @New_Is_Police_Report_Provided --Police Report Provided
		BEGIN
			DECLARE @Tbl_Fee_To_Revert as TABLE(
				Asset_Student_Fee_ID INT
			)
			
			insert into @Tbl_Fee_To_Revert
			select 
				ID
			from Asset_Student_Fee 
			where Asset_Student_Transaction_ID = @Asset_Student_Transaction_ID

			--Revert CAIRS Fees
			update Asset_Student_Fee 
				set 
					Is_Active = 0,
					Date_Modified = @Date,
					Modified_By_Emp_ID = @Emp_ID
			Where 1=1
				and ID in (select * from @Tbl_Fee_To_Revert)	
			
			--Revert MOSIS Fees
			Update MCS.dbo.StudentFees
				set 
					IsActive = 0,
					DateModified = @Date,
					ModifiedBy = @Emp_ID
			WHERE 1=1
				and Asset_Student_Fee_ID in (
					select * from @Tbl_Fee_To_Revert
				)	


			--Apply New Fee
			--Add Student Fee if needed
				IF @Stu_Responsible_For_Damage = '1' OR @New_Chk_In_Type_ID in ('2','3','4','6','7') --Check in Type (Lost, Stolen, Found, Return, Not Returned)
					BEGIN
						--This function will assess fees and determine amount. Includes returning and charging fees
						EXEC dbo.sp_Upsert_Asset_Student_Fee	-1,								--@ID
																null,							--@Student_Device_Coverage_ID
																@Asset_Student_Transaction_ID,	--@Asset_Student_Transaction_ID
																null,							--@Student_ID
																null,							--@Asset_ID
																null,							--@Asset_Base_Type_ID
																null,							--@Asset_Type_ID
																@New_Chk_In_Type_ID,			--@Check_In_Type_Code
																@New_Check_In_Disposition_ID,	--@Asset_Disposition_ID
																null,							--@Asset_Disposition_Desc
																@Is_Police_Report_Provided,		--@Is_Police_Report_Provided
																null,							--@Owed_Amount AS FLOAT
																null,							--@Date_Processed_School_Msg
																null,							--@Date_Processed_Fee
																@Comments,						--@Comments
																@Emp_ID,						--@Added_By_Emp_ID
																@Date,							--@Date_Added
																null,							--@Modified_By_Emp_ID
																null,							--@Date_Modified
																null							--@returnID
					END

		END

	END

END

GO
