USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_CT_Repair_Type]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_CT_Repair_Type]
	@ID AS INT,
	@Code AS VARCHAR(10) ,
	@Name AS VARCHAR(100) ,
	@Description AS VARCHAR(1000) = null,
	@Is_Active AS VARCHAR(30)
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.CT_Repair_Type
			(
				Code,
				Name,
				Description,
				Is_Active
			)
			SELECT 
				@Code,
				@Name,
				CASE WHEN @Description = '::DBNULL::' THEN NULL ELSE @Description END,
				@Is_Active

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.CT_Repair_Type where ID = @ID)
		BEGIN
			UPDATE dbo.CT_Repair_Type
			SET
				Code = @Code,
				Name = @Name,
				Description = CASE WHEN @Description = '::DBNULL::' THEN NULL WHEN @Description IS NULL THEN Description ELSE @Description END,
				Is_Active = @Is_Active
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END




GO
