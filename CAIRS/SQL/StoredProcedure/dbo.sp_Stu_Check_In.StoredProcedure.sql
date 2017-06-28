USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Stu_Check_In]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Create date: 02/20/2017 11:00:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Stu_Check_In]
	@Asset_Student_Transaction_ID AS INT = null,
	@Check_In_Type_Code AS VARCHAR(10),
	@Disposition_ID AS INT,
	@Is_Police_Report_Provided AS VARCHAR(30) = null,
	@Check_In_Condition_ID AS INT = null,
	@Bin_ID AS VARCHAR(10),
	@Comments AS VARCHAR(MAX),
	@Attachments AS XML,
	@Stu_Responsible_For_Damage AS VARCHAR(1) = null,
	@Emp_ID AS VARCHAR(11),
	@Date AS DateTime
AS
BEGIN
	DECLARE @Asset_ID AS INT
	DECLARE @Student_ID AS VARCHAR(20)
	DECLARE @Dispoistion_Desc AS VARCHAR(100)
	DECLARE @Old_Disposition_ID AS INT
	DECLARE @Old_Disposition_Desc AS VARCHAR(100)

	DECLARE @Condition_Desc AS VARCHAR(100)
	DECLARE @Old_Condition_ID AS INT
	DECLARE @Old_Condition_Desc AS VARCHAR(100)
	DECLARE @Check_In_Type_Found AS VARCHAR(10) = '4'
	DECLARE @Found_Disp_ID INT = 10
	DECLARE @Found_Disp_Desc VARCHAR(100) = 'Found'
	
	SET @Asset_ID = (SELECT Asset_ID from Asset_Student_Transaction where ID = @Asset_Student_Transaction_ID)
	SET @Student_ID = (SELECT Student_ID from Asset_Student_Transaction where ID = @Asset_Student_Transaction_ID)
	--disposition
	SET @Dispoistion_Desc = (SELECT dbo.GetAssetDispositionNameById(@Disposition_ID))
	SET @Old_Disposition_ID = (SELECT Asset_Disposition_ID FROM Asset WHERE ID = @Asset_ID)
	SET @Old_Disposition_Desc = (SELECT dbo.GetAssetDispositionNameById(@Old_Disposition_ID))
	--condition
	SET @Condition_Desc = (SELECT dbo.GetAssetConditionNameById(@Check_In_Condition_ID))
	SET @Old_Condition_ID = (SELECT Asset_Condition_ID FROM Asset WHERE ID = @Asset_ID)
	SET @Old_Condition_Desc = (SELECT dbo.GetAssetConditionNameById(@Old_Condition_ID))

	-------------------------------------------------------START Disposition-------------------------------------------------------
	--Needs to save asset disposition twice when checkin type is found for tracking purposes.
	IF @Check_In_Type_Code = @Check_In_Type_Found --Found
	BEGIN
			--Update Asset Audit
			EXEC dbo.sp_Insert_Audit_Log  'Asset', 
											@Asset_ID, 
											'Asset_Disposition_ID', 
											'Disposition', 
											@Old_Disposition_ID, 
											@Old_Disposition_Desc, 
											@Found_Disp_ID, 
											@Found_Disp_Desc, 
											@Emp_ID, 
											@Date

			--Update Asset
			Update Asset
				SET 
					Asset_Disposition_ID = @Found_Disp_ID
			WHERE ID = @Asset_ID
	END

	--Reset Value in case disposition was updated above
	SET @Old_Disposition_ID = (SELECT Asset_Disposition_ID FROM Asset WHERE ID = @Asset_ID)
	SET @Old_Disposition_Desc = (SELECT dbo.GetAssetDispositionNameById(@Old_Disposition_ID))

	--Only Update if it does not match
	IF @Disposition_ID <> @Old_Disposition_ID 
		BEGIN
			--Update Asset Audit
			EXEC dbo.sp_Insert_Audit_Log  'Asset', 
											@Asset_ID, 
											'Asset_Disposition_ID', 
											'Disposition', 
											@Old_Disposition_ID, 
											@Old_Disposition_Desc, 
											@Disposition_ID, 
											@Dispoistion_Desc, 
											@Emp_ID, 
											@Date
			
			--Update Asset
			Update Asset
				SET 
					Asset_Disposition_ID = @Disposition_ID
			WHERE ID = @Asset_ID
		END
	-------------------------------------------------------END Disposition-------------------------------------------------------
	

	-------------------------------------------------------START Bin Assignment---------------------------------------------------
	IF @Bin_ID is not null 
		BEGIN
			EXEC dbo.sp_Assign_Asset_To_Bin @Bin_ID,
											@Asset_ID,
											@Emp_ID,
											@Date
		END
	-------------------------------------------------------END Bin Assignment---------------------------------------------------
	

	-------------------------------------------------------START Comment---------------------------------------------------
	--Add comments to asset_comment
	if len(@Comments) > 0
		BEGIN
			EXEC dbo.sp_Upsert_Asset_Comment  -1, 
											@Asset_ID, 
											@Comments,
											@Emp_ID, 
											@Date,
											null,
											null
		END
	-------------------------------------------------------END Comment---------------------------------------------------


	-------------------------------------------------------START Attachment---------------------------------------------------
	--Need to parse xml to insert record
	IF @Attachments IS NOT NULL
		BEGIN
			DECLARE @XML_Table AS TABLE (ItemXml XML)
			DECLARE @Attachment_Table as TABLE (
				File_Type_ID INT,
				File_Type_Desc VARCHAR(100),
				Name VARCHAR(100),
				Description Varchar(1000)
			)

			INSERT INTO @XML_Table SELECT @Attachments

			INSERT INTO @Attachment_Table
			SELECT
				CAST(ft.id as Varchar(100)) as File_Type_ID, 
				CAST(attachment.query('data(File_Type_Desc)') as VARCHAR(100)) AS File_Type_Desc,
				CAST(attachment.query('data(Name)') as VARCHAR(100)) AS Name,
				CAST(attachment.query('data(Description)') as VARCHAR(1000)) AS Description
			FROM  @XML_Table
			CROSS APPLY @Attachments.nodes('Attachments/Attachment') x(attachment)
			CROSS APPLY @Attachments.nodes('Attachments') y(attachments)
			left join CT_File_Type ft
				on ft.Name = CAST(attachment.query('data(File_Type_Desc)') as VARCHAR(100))

			INSERT INTO Asset_Attachment
			select 
				@Asset_ID,
				@Student_ID,
				null as Asset_Tamper_ID,
				a.File_Type_ID,
				a.Name,
				a.Description,
				@Emp_ID,
				@Date,
				null,
				null
			from @Attachment_Table a
		END
	-------------------------------------------------------END Attachment---------------------------------------------------


	-------------------------------------------------------START Interaction---------------------------------------------------
	--If Disposition Interaction
	IF @Disposition_ID = 17
		BEGIN
			--Insert Student Transaction
			EXEC sp_Upsert_Asset_Student_Transaction_Interaction -1,
																 @Asset_Student_Transaction_ID,
																 '1', --Unidentified Interaction 
																 @Comments,
																 @Emp_ID,
																 @Date,
																 null,
																 null,
																 null
		END
	-------------------------------------------------------END Interaction---------------------------------------------------
	--If Disposition Interaction


	-------------------------------------------------------START Asset Student Transaction---------------------------------------------------
	--Disposition is not in "Research, Unidentified, Evaluate Condition"
	IF @Disposition_ID NOT IN (16,17,1004)
		BEGIN
			--Variable used to update Asset Student Transaction
			DECLARE @Chk_In_Emp_ID AS VARCHAR(11) = @Emp_ID
			DECLARE @Chk_In_Disposition_ID AS VARCHAR(30) = @Disposition_ID
			DECLARE @Chk_In_Cond_ID AS VARCHAR(30) = @Check_In_Condition_ID
			DECLARE @Chk_In_Date AS DATETIME = @Date
			DECLARE @Chk_In_Comments VARCHAR(MAX) =  @Comments
			DECLARE @Found_Date AS DATETIME = null
			DECLARE @Found_Disposition AS VARCHAR(30) = null
			DECLARE @Found_Condition_ID AS VARCHAR(30) = null
		
			--If Check In Type is found, set the disposition to found for the Asset Student Tranasaction
			--The Asset Disposition can be different in this case
			IF @Check_In_Type_Code = @Check_In_Type_Found --Found
				BEGIN
					SET @Chk_In_Disposition_ID = @Found_Disp_ID

					--Check to see if this Found item was previously checked in. This item may have been checked in as Lost or Stolen.
					IF EXISTS (SELECT 1 FROM Asset_Student_Transaction WHERE ID = @Asset_Student_Transaction_ID and Date_Check_In IS NOT NULL)
						BEGIN
							SET @Chk_In_Disposition_ID = null
							SET @Chk_In_Cond_ID = null
							SET @Chk_In_Emp_ID = null
							SET @Chk_In_Date = null
							SET @Chk_In_Comments = null

							SET @Found_Date = @Date
							SET @Found_Disposition = @Disposition_ID
							SET @Found_Condition_ID = @Check_In_Condition_ID
						END
				END
		
			--Update Asset_Student_Transaction Check-In
			EXEC dbo.sp_Upsert_Asset_Student_Transaction @Asset_Student_Transaction_ID, --ID
														 null, --Asset_ID
														 null, --Student_ID
														 null, --Student_School_Number
														 null, --School_Year
														 null, --Check_Out_Asset_Condition_ID
														 null, --Check_Out_Emp_ID
														 null, --Date_Check_out
														 @Chk_In_Cond_ID, --Check_In_Asset_Condition_ID
														 @Chk_In_Emp_ID, --Check_In_Emp_ID
														 @Chk_In_Date, --Check_In_Date
														 @Chk_In_Comments, --Comments
														 @Chk_In_Disposition_ID, --Check_In_Disposition_ID
														 @Found_Date,
														 @Found_Disposition,
														 @Found_Condition_ID,
														 @Stu_Responsible_For_Damage,
														 null --Return ID

			--Condition
			IF @Check_In_Condition_ID <> @Old_Condition_ID AND @Check_In_Condition_ID is not null
				BEGIN

					--Condition
					EXEC dbo.sp_Insert_Audit_Log  'Asset',
													@Asset_ID,
													'Asset_Condition_ID',
													'Condition',
													@Old_Condition_ID,
													@Old_Condition_Desc,
													@Check_In_Condition_ID,
													@Condition_Desc,
													@Emp_ID,
													@Date
			
					--Update Asset
					Update Asset
						SET 
							Asset_Condition_ID = @Check_In_Condition_ID
					WHERE ID = @Asset_ID
				END

			--Add Student Fee if needed
			IF @Stu_Responsible_For_Damage = '1'
				BEGIN
					EXEC dbo.sp_Upsert_Asset_Student_Fee	-1,								--@ID
															null,							--@Student_Device_Coverage_ID
															@Asset_Student_Transaction_ID,	--@Asset_Student_Transaction_ID
															null,							--@Student_ID
															null,							--@Asset_ID
															null,							--@Asset_Base_Type_ID
															null,							--@Asset_Type_ID
															@Check_In_Type_Code,			--@Check_In_Type_Code
															@Disposition_ID,				--@Asset_Disposition_ID
															null,							--@Asset_Disposition_Desc
															@Is_Police_Report_Provided,		--@Is_Police_Report_Provided
															null,							--@Owed_Amount AS FLOAT
															null,							--@Date_Processed_School_Msg
															null,							--@Date_Processed_Fee
															@Emp_ID,						--@Added_By_Emp_ID
															@Date,							--@Date_Added
															null,							--@Modified_By_Emp_ID
															null,							--@Date_Modified
															null							--@returnID
				END

		END
	-------------------------------------------------------END Asset Student Transaction---------------------------------------------------
END






GO
