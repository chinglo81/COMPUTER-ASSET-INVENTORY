USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Bin]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Bin]
	@ID AS INT,
	@Site_ID AS INT,
	@Description AS VARCHAR(1000) = null,
	@Capacity AS VARCHAR(10) = null,
	@Is_Active AS VARCHAR(30),
	@Added_By_Emp_ID AS VARCHAR(11) ,
	@Date_Added AS VARCHAR(30),
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null
AS
BEGIN
	-- Return Value
	DECLARE @returnid int
	DECLARE @Bin_Number int 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			--Get the maxnumber by site and increment by 1
			SET @Bin_Number = (select isnull(Max(Number), 0) + 1 from Bin where Site_ID = @Site_ID)

			INSERT INTO dbo.Bin
			(
				Site_ID,
				Number,
				Description,
				Capacity,
				Is_Active,
				Added_By_Emp_ID,
				Date_Added
			)
			SELECT 
				@Site_ID,
				@Bin_Number,
				CASE WHEN @Description = '::DBNULL::' THEN NULL ELSE @Description END,
				CASE WHEN @Capacity = '::DBNULL::' THEN NULL ELSE @Capacity END,
				@Is_Active,
				@Added_By_Emp_ID,
				@Date_Added

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Bin where ID = @ID)
		BEGIN
			--Only allow these fields to be updated.
			UPDATE dbo.Bin
			SET
				Description = CASE WHEN @Description = '::DBNULL::' THEN NULL WHEN @Description IS NULL THEN Description ELSE @Description END,
				Capacity = CASE WHEN @Capacity = '::DBNULL::' THEN NULL WHEN @Capacity IS NULL THEN Capacity ELSE @Capacity END,
				Is_Active = @Is_Active,
				Modified_By_Emp_ID = CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Modified_By_Emp_ID IS NULL THEN Modified_By_Emp_ID ELSE @Modified_By_Emp_ID END,
				Date_Modified = CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL WHEN @Date_Modified IS NULL THEN Date_Modified ELSE @Date_Modified END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END





GO
