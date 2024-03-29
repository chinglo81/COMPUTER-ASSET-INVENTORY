USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_CT_Asset_Type]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_CT_Asset_Type]
	@ID AS INT,
	@Code AS VARCHAR(10) ,
	@Name AS VARCHAR(100) ,
	@Description AS VARCHAR(1000) = null,
	@Asset_Baset_Type_ID AS INT,
	@Vendor_ID AS INT = null,
	@Is_Vendor_Req AS VARCHAR(30),
	@Is_Serial_Req AS VARCHAR(30),
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
			INSERT INTO dbo.CT_Asset_Type
			(
				Code,
				Name,
				Description,
				Asset_Base_Type_ID,
				Vendor_ID,
				Is_Vendor_Req,
				Is_Serial_Req,
				Is_Active
			)
			SELECT 
				@Code,
				@Name,
				CASE WHEN @Description = '::DBNULL::' THEN NULL ELSE @Description END,
				@Asset_Baset_Type_ID,
				CASE WHEN @Vendor_ID = '::DBNULL::' THEN NULL ELSE @Vendor_ID END,
				@Is_Vendor_Req,
				@Is_Serial_Req,
				@Is_Active

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.CT_Asset_Type where ID = @ID)
		BEGIN
			UPDATE dbo.CT_Asset_Type
			SET
				Code = case when @Code is null then Code else @Code end,
				Name = case when @Name is null then Name else @Name end,
				Description = CASE WHEN @Description = '::DBNULL::' THEN NULL WHEN @Description IS NULL THEN Description ELSE @Description END,
				Asset_Base_Type_ID = case when @Asset_Baset_Type_ID is null then Asset_Base_Type_ID else @Asset_Baset_Type_ID end,
				Vendor_ID = CASE WHEN @Vendor_ID = '::DBNULL::' THEN NULL WHEN @Vendor_ID IS NULL THEN Vendor_ID ELSE @Vendor_ID END,
				Is_Vendor_Req = case when @Is_Vendor_Req is null then Is_Vendor_Req else @Is_Vendor_Req end,
				Is_Serial_Req = case when @Is_Serial_Req is null then Is_Serial_Req else @Is_Serial_Req end,
				Is_Active = case when @Is_Active is null then Is_Active else @Is_Active end
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END




GO
