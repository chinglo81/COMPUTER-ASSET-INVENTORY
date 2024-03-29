USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Temp_Detail]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Temp_Detail]
	@ID AS INT,
	@Asset_Temp_Header_ID AS INT,
	@Tag_ID AS VARCHAR(100) ,
	@Asset_Disposition_ID AS INT,
	@Asset_Condition_ID AS INT,
	@Asset_Type_ID AS INT,
	@Asset_Assignment_Type_ID AS INT,
	@Bin_ID AS VARCHAR(30) = null,
	@Serial_Number AS VARCHAR(100) = null,
	@Date_Purchased AS VARCHAR(30) = null,
	@Is_Leased AS VARCHAR(30) = null,
	@Date_Added AS VARCHAR(30),
	@Added_By_Emp_ID AS VARCHAR(11) 
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Temp_Detail
			(
				Asset_Temp_Header_ID,
				Tag_ID,
				Asset_Disposition_ID,
				Asset_Condition_ID,
				Asset_Type_ID,
				Asset_Assignment_Type_ID,
				Bin_ID,
				Serial_Number,
				Date_Purchased,
				Is_Leased,
				Date_Added,
				Added_By_Emp_ID
			)
			SELECT 
				@Asset_Temp_Header_ID,
				@Tag_ID,
				@Asset_Disposition_ID,
				@Asset_Condition_ID,
				@Asset_Type_ID,
				@Asset_Assignment_Type_ID,
				CASE WHEN @Bin_ID = '::DBNULL::' THEN NULL ELSE @Bin_ID END,
				CASE WHEN @Serial_Number = '::DBNULL::' THEN NULL ELSE @Serial_Number END,
				CASE WHEN @Date_Purchased = '::DBNULL::' THEN NULL ELSE @Date_Purchased END,
				CASE WHEN @Is_Leased = '::DBNULL::' THEN NULL ELSE @Is_Leased END,
				@Date_Added,
				@Added_By_Emp_ID

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Temp_Detail where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Temp_Detail
			SET
				Asset_Temp_Header_ID = @Asset_Temp_Header_ID,
				Tag_ID = @Tag_ID,
				Asset_Disposition_ID = @Asset_Disposition_ID,
				Asset_Condition_ID = @Asset_Condition_ID,
				Asset_Type_ID = @Asset_Type_ID,
				Asset_Assignment_Type_ID = @Asset_Assignment_Type_ID,
				Bin_ID = CASE WHEN @Bin_ID = '::DBNULL::' THEN NULL WHEN @Bin_ID IS NULL THEN Bin_ID ELSE @Bin_ID END,
				Serial_Number = CASE WHEN @Serial_Number = '::DBNULL::' THEN NULL WHEN @Serial_Number IS NULL THEN Serial_Number ELSE @Serial_Number END,
				Date_Purchased = CASE WHEN @Date_Purchased = '::DBNULL::' THEN NULL WHEN @Date_Purchased IS NULL THEN Date_Purchased ELSE @Date_Purchased END,
				Is_Leased = CASE WHEN @Is_Leased = '::DBNULL::' THEN NULL WHEN @Is_Leased IS NULL THEN Is_Leased ELSE @Is_Leased END

			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
