USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_CT_Asset_Type]    Script Date: 2/3/2017 10:35:31 AM ******/
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
	@Vendor_ID AS INT = null,
	@Is_Vendor_Req AS VARCHAR(30),
	@Is_Serial_Req AS VARCHAR(30),
	@Max_Checkout AS INT,
	@Warranty_Days AS INT = null,
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
				Vendor_ID,
				Is_Vendor_Req,
				Is_Serial_Req,
				Max_Checkout,
				Warranty_Days,
				Is_Active
			)
			SELECT 
				@Code,
				@Name,
				CASE WHEN @Description = '::DBNULL::' THEN NULL ELSE @Description END,
				CASE WHEN @Vendor_ID = '::DBNULL::' THEN NULL ELSE @Vendor_ID END,
				@Is_Vendor_Req,
				@Is_Serial_Req,
				@Max_Checkout,
				CASE WHEN @Warranty_Days = '::DBNULL::' THEN NULL ELSE @Warranty_Days END,
				@Is_Active

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.CT_Asset_Type where ID = @ID)
		BEGIN
			UPDATE dbo.CT_Asset_Type
			SET
				Code = @Code,
				Name = @Name,
				Description = CASE WHEN @Description = '::DBNULL::' THEN NULL WHEN @Description IS NULL THEN Description ELSE @Description END,
				Vendor_ID = CASE WHEN @Vendor_ID = '::DBNULL::' THEN NULL WHEN @Vendor_ID IS NULL THEN Vendor_ID ELSE @Vendor_ID END,
				Is_Vendor_Req = @Is_Vendor_Req,
				Is_Serial_Req = @Is_Serial_Req,
				Max_Checkout = @Max_Checkout,
				Warranty_Days = CASE WHEN @Warranty_Days = '::DBNULL::' THEN NULL WHEN @Warranty_Days IS NULL THEN Warranty_Days ELSE @Warranty_Days END,
				Is_Active = @Is_Active
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
