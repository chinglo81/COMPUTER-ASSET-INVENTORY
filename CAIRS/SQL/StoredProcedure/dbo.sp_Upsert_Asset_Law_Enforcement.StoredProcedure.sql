USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Law_Enforcement]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 06/09/2017 10:11:51 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Law_Enforcement]
	@ID AS INT,
	@Asset_ID AS INT = null,
	@Law_Enforcement_Agency_ID AS INT = null, 
	@Officer_First_Name AS VARCHAR(100) = null,
	@Officer_Last_Name AS VARCHAR(100) = null,
	@Case_Number AS VARCHAR(100) = null,
	@Comment AS VARCHAR(max) = null,
	@Date_Picked_Up AS VARCHAR(30) = null,
	@Date_Returned AS VARCHAR(30) = null,
	@Received_By_Emp_ID AS VARCHAR(11) = null,
	@Added_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Added AS VARCHAR(30) = null,
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.Asset_Law_Enforcement
			(
				Asset_ID,
				Law_Enforcement_Agency_ID,
				Officer_First_Name,
				Officer_Last_Name,
				Case_Number,
				Comment,
				Date_Picked_Up,
				Date_Returned,
				Received_By_Emp_ID,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_ID,
				@Law_Enforcement_Agency_ID,
				@Officer_First_Name,
				@Officer_Last_Name,
				@Case_Number,
				CASE WHEN @Comment = '::DBNULL::' THEN NULL ELSE @Comment END,
				CASE WHEN @Date_Picked_Up = '::DBNULL::' THEN NULL ELSE @Date_Picked_Up END,
				CASE WHEN @Date_Returned = '::DBNULL::' THEN NULL ELSE @Date_Returned END,
				CASE WHEN @Received_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Received_By_Emp_ID END,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Law_Enforcement where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Law_Enforcement
			SET
				Law_Enforcement_Agency_ID = CASE WHEN @Law_Enforcement_Agency_ID IS NULL THEN Law_Enforcement_Agency_ID ELSE @Law_Enforcement_Agency_ID END,
				Officer_First_Name = CASE WHEN @Officer_First_Name = '::DBNULL::' THEN NULL WHEN @Officer_First_Name IS NULL THEN Officer_First_Name ELSE @Officer_First_Name END,
				Officer_Last_Name = CASE WHEN @Officer_Last_Name = '::DBNULL::' THEN NULL WHEN @Officer_Last_Name IS NULL THEN Officer_Last_Name ELSE @Officer_Last_Name END,
				Case_Number = CASE WHEN @Case_Number IS NULL THEN Case_Number ELSE @Case_Number END,
				Comment = CASE WHEN @Comment = '::DBNULL::' THEN NULL WHEN @Comment IS NULL THEN Comment ELSE @Comment END,
				Date_Picked_Up = CASE WHEN @Date_Picked_Up = '::DBNULL::' THEN NULL WHEN @Date_Picked_Up IS NULL THEN Date_Picked_Up ELSE @Date_Picked_Up END,
				Date_Returned = CASE WHEN @Date_Returned = '::DBNULL::' THEN NULL WHEN @Date_Returned IS NULL THEN Date_Returned ELSE @Date_Returned END,
				Received_By_Emp_ID = CASE WHEN @Received_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Received_By_Emp_ID IS NULL THEN Received_By_Emp_ID ELSE @Received_By_Emp_ID END,
				Modified_By_Emp_ID = @Modified_By_Emp_ID,
				Date_Modified = @Date_Modified

			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
