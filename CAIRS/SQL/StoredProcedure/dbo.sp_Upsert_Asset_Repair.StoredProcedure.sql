USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Repair]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Create date: 1/27/2017 2:30:51 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Repair]
	@ID AS INT,
	@Asset_ID AS INT,
	@Repair_Type_ID AS INT,
	@Comment AS VARCHAR(max) = null,
	@Date_Sent AS VARCHAR(30) = null,
	@Date_Received AS VARCHAR(30) = null,
	@Received_By_Emp_ID as VARCHAR(11) = null,
	@Received_Disposition_ID as VARCHAR(30) = null,
	@Added_By_Emp_ID AS VARCHAR(11),
	@Date_Added AS VARCHAR(30),
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
			INSERT INTO dbo.Asset_Repair
			(
				Asset_ID,
				Is_Leased,
				Repair_Type_ID,
				Comment,
				Date_Sent,
				Date_Received,
				Received_By_Emp_ID,
				Received_Disposition_ID,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_ID,
				(SELECT isnull(Is_Leased, 0) from Asset where ID=@Asset_ID),
				@Repair_Type_ID,
				CASE WHEN @Comment = '::DBNULL::' THEN NULL ELSE @Comment END,
				CASE WHEN @Date_Sent = '::DBNULL::' THEN NULL ELSE @Date_Sent END,
				CASE WHEN @Date_Received = '::DBNULL::' THEN NULL ELSE @Date_Received END,
				CASE WHEN @Received_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Received_By_Emp_ID END,
				CASE WHEN @Received_Disposition_ID = '::DBNULL::' THEN NULL ELSE @Received_Disposition_ID END,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Repair where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Repair
			SET
				Asset_ID =  CASE WHEN @Asset_ID IS NULL THEN Asset_ID ELSE @Asset_ID END,
				Repair_Type_ID = CASE WHEN @Repair_Type_ID IS NULL THEN Repair_Type_ID ELSE @Repair_Type_ID END,
				Comment = CASE WHEN @Comment = '::DBNULL::' THEN NULL WHEN @Comment IS NULL THEN Comment ELSE @Comment END,
				Date_Sent = CASE WHEN @Date_Sent = '::DBNULL::' THEN NULL WHEN @Date_Sent IS NULL THEN Date_Sent ELSE @Date_Sent END,
				Date_Received = CASE WHEN @Date_Received = '::DBNULL::' THEN NULL WHEN @Date_Received IS NULL THEN Date_Received ELSE @Date_Received END,
				Received_By_Emp_ID = CASE WHEN @Received_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Received_By_Emp_ID IS NULL THEN Received_By_Emp_ID ELSE @Received_By_Emp_ID END,
				Received_Disposition_ID = CASE WHEN @Received_Disposition_ID = '::DBNULL::' THEN NULL WHEN @Received_Disposition_ID IS NULL THEN Received_Disposition_ID ELSE @Received_Disposition_ID END,
				Modified_By_Emp_ID = CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Modified_By_Emp_ID IS NULL THEN Modified_By_Emp_ID ELSE @Modified_By_Emp_ID END,
				Date_Modified = CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL WHEN @Date_Modified IS NULL THEN Date_Modified ELSE @Date_Modified END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END





GO
