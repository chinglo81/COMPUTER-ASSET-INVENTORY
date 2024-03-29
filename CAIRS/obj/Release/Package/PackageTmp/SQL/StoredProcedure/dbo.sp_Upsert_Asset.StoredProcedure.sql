USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery10.sql|9|0|C:\Users\lo.c\AppData\Local\Temp\~vsCC17.sql




-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset]
	@ID AS INT,
	@Tag_ID AS VARCHAR(100) ,
	@Asset_Disposition_ID AS INT,
	@Asset_Condition_ID AS INT,
	@Asset_Type_ID AS INT,
	@Asset_Assignment_Type_ID AS INT,
	@Serial_Number AS VARCHAR(100) = null,
	@Date_Purchased AS VARCHAR(30) = null,
	@Is_Leased AS VARCHAR(30) = null,
	@Is_Active AS VARCHAR(30),
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30) = null,
	@Modified_By_Emp_ID AS VARCHAR(11),
	@Date_Modified As VARCHAR(30),
	@ReturnID as int = null OUTPUT 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset
			(
				Tag_ID,
				Asset_Disposition_ID,
				Asset_Condition_ID,
				Asset_Type_ID,
				Asset_Assignment_Type_ID,
				Serial_Number,
				Date_Purchased,
				Is_Leased,
				Is_Active,
				Added_By_Emp_ID,
				Date_Added
			)
			SELECT 
				@Tag_ID,
				@Asset_Disposition_ID,
				@Asset_Condition_ID,
				@Asset_Type_ID,
				@Asset_Assignment_Type_ID,
				CASE WHEN @Serial_Number = '::DBNULL::' THEN NULL ELSE @Serial_Number END,
				CASE WHEN @Date_Purchased = '::DBNULL::' THEN NULL ELSE @Date_Purchased END,
				CASE WHEN @Is_Leased = '::DBNULL::' THEN NULL ELSE @Is_Leased END,
				@Is_Active,
				@Added_By_Emp_ID,
				CASE WHEN @Date_Added = '::DBNULL::' THEN NULL ELSE @Date_Added END

			SET @ReturnID = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset where ID = @ID)
		BEGIN
			--Save Audit
			--EXEC sp_Upsert_Asset_Audit_Log(
			DECLARE @Tag_ID_OLD_VALUE AS VARCHAR(100)
			DECLARE @Asset_Disposition_ID_OLD_VALUE AS INT
			DECLARE @Asset_Disposition_ID_OLD_VALUE_DESC AS VARCHAR(100)
			DECLARE @Asset_Condition_ID_OLD_VALUE AS INT
			DECLARE @Asset_Condition_ID_OLD_VALUE_DESC AS VARCHAR(100)
			DECLARE @Asset_Type_ID_OLD_VALUE AS INT
			DECLARE @Asset_Type_ID_OLD_VALUE_DESC AS VARCHAR(100)
			DECLARE @Asset_Assignment_Type_ID_OLD_VALUE AS INT
			DECLARE @Asset_Assignment_Type_ID_OLD_VALUE_DESC AS VARCHAR(100)
			DECLARE @Serial_Number_OLD_VALUE AS VARCHAR(100)
			DECLARE @Date_Purchased_OLD_VALUE AS VARCHAR(30)
			DECLARE @Is_Leased_OLD_VALUE AS VARCHAR(30)
			DECLARE @Is_Leased_OLD_VALUE_DESC AS VARCHAR(30)
			DECLARE @Is_Active_OLD_VALUE AS VARCHAR(30)
			DECLARE @Is_Active_OLD_VALUE_DESC AS VARCHAR(30)


			DECLARE @Table_Name AS VARCHAR(100) = 'Asset';
			DECLARE @NewValueDesc AS VARCHAR(100)

			--Declare temp table to and insert old value
			DECLARE @AssetTempTbl TABLE(
				Tag_ID VARCHAR(100),
				Asset_Disposition_ID INT,
				Asset_Disposition_Desc VARCHAR(100),
				Asset_Condition_ID INT,
				Asset_Condition_Desc VARCHAR(100),
				Asset_Type_ID INT,
				Asset_Type_Desc VARCHAR(100),
				Asset_Assignment_Type_ID INT,
				Asset_Assignment_Type_Desc VARCHAR(100),
				Serial_Number VARCHAR(100),
				Date_Purchased VARCHAR(30),
				Is_Leased VARCHAR(30),
				Is_Leased_Desc VARCHAR(30),
				Is_Active VARCHAR(30),
				Is_Active_Desc VARCHAR(30)
			)
			INSERT INTO @AssetTempTbl
			select
				Tag_ID, 
				Asset_Disposition_ID, 
				dbo.GetAssetDispositionNameById(Asset_Disposition_ID) AS Asset_Disposition_Desc,
				Asset_Condition_ID, 
				dbo.GetAssetConditionNameById(Asset_Condition_ID) AS Asset_Condition_Desc,
				Asset_Type_ID,
				dbo.GetAssetTypeNameById(Asset_Type_ID) AS Asset_Type_Desc,
				Asset_Assignment_Type_ID,
				dbo.GetAssetAssignmentTypeNameById(Asset_Assignment_Type_ID) AS Asset_Assignment_Type_Desc,
				Serial_Number, 
				Date_Purchased, 
				Is_Leased,
				CASE WHEN Is_Leased = 1 THEN 'Yes' ELSE 'No' END AS Is_Leased_Desc,
				Is_Active,
				CASE WHEN Is_Active = 1 THEN 'Yes' ELSE 'No' END AS Is_Active_Desc
			from dbo.Asset
			where ID = @ID

			--Tag ID
			set @Tag_ID_OLD_VALUE = (SELECT Tag_ID from @AssetTempTbl)
			IF @Tag_ID <> @Tag_ID_OLD_VALUE AND @Tag_ID IS NOT NULL OR (@Tag_ID = '::DBNULL::' AND @Tag_ID_OLD_VALUE IS NOT NULL)
			BEGIN
				SET @NewValueDesc = @Tag_ID
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Tag_ID', 'Tag ID', @Tag_ID_OLD_VALUE, @Tag_ID_OLD_VALUE, @Tag_ID, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--Disposition
			set @Asset_Disposition_ID_OLD_VALUE = (SELECT Asset_Disposition_ID from @AssetTempTbl)
			set @Asset_Disposition_ID_OLD_VALUE_DESC = (SELECT Asset_Disposition_Desc from @AssetTempTbl)
			IF @Asset_Disposition_ID <> @Asset_Disposition_ID_OLD_VALUE AND @Asset_Disposition_ID IS NOT NULL 
			BEGIN
				SET @NewValueDesc = (select dbo.GetAssetDispositionNameById(@Asset_Disposition_ID))
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Asset_Disposition_ID', 'Disposition', @Asset_Disposition_ID_OLD_VALUE, @Asset_Disposition_ID_OLD_VALUE_DESC, @Asset_Disposition_ID, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified	
			END

			--Condition
			set @Asset_Condition_ID_OLD_VALUE = (SELECT Asset_Condition_ID from @AssetTempTbl)
			set @Asset_Condition_ID_OLD_VALUE_DESC = (SELECT Asset_Condition_Desc from @AssetTempTbl)
			IF @Asset_Condition_ID <> @Asset_Condition_ID_OLD_VALUE AND @Asset_Condition_ID IS NOT NULL 
			BEGIN
				SET @NewValueDesc = (select dbo.GetAssetConditionNameById(@Asset_Condition_ID))
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Asset_Condition_ID', 'Condition', @Asset_Condition_ID_OLD_VALUE, @Asset_Condition_ID_OLD_VALUE_DESC, @Asset_Condition_ID, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--Asset Type
			set @Asset_Type_ID_OLD_VALUE = (SELECT Asset_Type_ID from @AssetTempTbl)
			set @Asset_Type_ID_OLD_VALUE_DESC = (SELECT Asset_Type_Desc from @AssetTempTbl)
			IF @Asset_Type_ID <> @Asset_Type_ID_OLD_VALUE AND @Asset_Type_ID IS NOT NULL 
			BEGIN
				SET @NewValueDesc = (select dbo.GetAssetTypeNameById(@Asset_Type_ID))
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Asset_Type_ID', 'Asset Type', @Asset_Type_ID_OLD_VALUE, @Asset_Type_ID_OLD_VALUE_DESC, @Asset_Type_ID, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--Asset Assignment Type
			set @Asset_Assignment_Type_ID_OLD_VALUE = (SELECT Asset_Assignment_Type_ID from @AssetTempTbl)
			set @Asset_Assignment_Type_ID_OLD_VALUE_DESC = (SELECT Asset_Assignment_Type_Desc from @AssetTempTbl)
			IF @Asset_Assignment_Type_ID <> @Asset_Assignment_Type_ID_OLD_VALUE AND @Asset_Assignment_Type_ID IS NOT NULL
			BEGIN
				SET @NewValueDesc = (select dbo.GetAssetAssignmentTypeNameById(@Asset_Assignment_Type_ID))
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Asset_Assignment_Type_ID', 'Assignment Type', @Asset_Assignment_Type_ID_OLD_VALUE, @Asset_Assignment_Type_ID_OLD_VALUE_DESC, @Asset_Assignment_Type_ID, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--Serial Number
			set @Serial_Number_OLD_VALUE = (SELECT Serial_Number from @AssetTempTbl)
			IF @Serial_Number <> @Serial_Number_OLD_VALUE AND @Serial_Number IS NOT NULL OR (@Serial_Number = '::DBNULL::' AND @Serial_Number_OLD_VALUE IS NOT NULL)
			BEGIN
				SET @NewValueDesc = @Serial_Number
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Serial_Number', 'Serial Number', @Serial_Number_OLD_VALUE, @Serial_Number_OLD_VALUE, @Serial_Number, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--Date Purchased
			set @Date_Purchased_OLD_VALUE = (SELECT Date_Purchased from @AssetTempTbl)
			IF @Date_Purchased <> @Date_Purchased_OLD_VALUE AND @Date_Purchased IS NOT NULL OR (@Date_Purchased = '::DBNULL::' AND @Date_Purchased_OLD_VALUE IS NOT NULL)
			BEGIN
				SET @NewValueDesc = @Date_Purchased
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Date_Purchased', 'Date Purchased', @Date_Purchased_OLD_VALUE, @Date_Purchased_OLD_VALUE, @Date_Purchased, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--Is Leased
			set @Is_Leased_OLD_VALUE = (SELECT Is_Leased from @AssetTempTbl)
			set @Is_Leased_OLD_VALUE_DESC = (SELECT Is_Leased_Desc from @AssetTempTbl)
			IF @Is_Leased <> @Is_Leased_OLD_VALUE AND @Is_Leased IS NOT NULL OR (@Is_Leased = '::DBNULL::' AND @Is_Leased_OLD_VALUE IS NOT NULL)
			BEGIN
				SET @NewValueDesc = (CASE WHEN @Is_Leased = '1' THEN 'Yes' ELSE 'No' END)
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Is_Leased', 'Is Leased', @Is_Leased_OLD_VALUE, @Is_Leased_OLD_VALUE_DESC, @Is_Leased, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified
			END

			--IsActive
			set @Is_Active_OLD_VALUE = (SELECT Is_Active from @AssetTempTbl)
			set @Is_Active_OLD_VALUE_DESC = (SELECT Is_Active_Desc from @AssetTempTbl)
			IF @Is_Active <> @Is_Active_OLD_VALUE AND @Is_Active IS NOT NULL
			BEGIN
				SET @NewValueDesc = (CASE WHEN @Is_Active = '1' THEN 'Yes' ELSE 'No' END)
				EXEC dbo.sp_Insert_Audit_Log @Table_Name, @ID, 'Is_Active', 'Is Active', @Is_Active_OLD_VALUE, @Is_Active_OLD_VALUE_DESC, @Is_Active_OLD_VALUE, @NewValueDesc, @Modified_By_Emp_ID, @Date_Modified

			END

			--Update Table
			UPDATE dbo.Asset
			SET
				Tag_ID = CASE WHEN @Tag_ID IS NULL THEN Tag_ID ELSE @Tag_ID END,
				Asset_Disposition_ID = CASE WHEN @Asset_Disposition_ID IS NULL THEN Asset_Disposition_ID ELSE @Asset_Disposition_ID END,
				Asset_Condition_ID = CASE WHEN @Asset_Disposition_ID IS NULL THEN Asset_Condition_ID ELSE @Asset_Disposition_ID END,
				Asset_Type_ID = CASE WHEN @Asset_Disposition_ID IS NULL THEN Asset_Type_ID ELSE @Asset_Type_ID END,
				Asset_Assignment_Type_ID = CASE WHEN @Asset_Assignment_Type_ID IS NULL THEN Asset_Assignment_Type_ID ELSE @Asset_Assignment_Type_ID END,
				Serial_Number = CASE WHEN @Serial_Number = '::DBNULL::' THEN NULL WHEN @Serial_Number IS NULL THEN Serial_Number ELSE @Serial_Number END,
				Date_Purchased = CASE WHEN @Date_Purchased = '::DBNULL::' THEN NULL WHEN @Date_Purchased IS NULL THEN Date_Purchased ELSE @Date_Purchased END,
				Is_Leased = CASE WHEN @Is_Leased = '::DBNULL::' THEN NULL WHEN @Is_Leased IS NULL THEN Is_Leased ELSE @Is_Leased END,
				Is_Active = CASE WHEN @Is_Active IS NULL THEN Is_Active ELSE @Is_Active END

			WHERE ID = @ID

			SET @ReturnID = @ID

		END

		SELECT @ReturnID
END







GO
