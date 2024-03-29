USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_CT_Asset_Type_Fee_Schedule]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/17/2017 9:55:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_CT_Asset_Type_Fee_Schedule]
	@ID AS INT,
	@Code AS VARCHAR(10) ,
	@Fee_Type_ID AS INT,
	@Fee_Amount AS FLOAT,
	@Date_Start AS VARCHAR(30),
	@Date_End AS VARCHAR(30) = null
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			INSERT INTO dbo.CT_Asset_Type_Fee_Schedule
			(
				Code,
				Fee_Type_ID,
				Fee_Amount,
				Date_Start,
				Date_End
			)
			SELECT 
				@Code,
				@Fee_Type_ID,
				@Fee_Amount,
				@Date_Start,
				CASE WHEN @Date_End = '::DBNULL::' THEN NULL ELSE @Date_End END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.CT_Asset_Type_Fee_Schedule where ID = @ID)
		BEGIN
			UPDATE dbo.CT_Asset_Type_Fee_Schedule
			SET
				Code = @Code,
				Fee_Type_ID = @Fee_Type_ID,
				Fee_Amount = @Fee_Amount,
				Date_Start = @Date_Start,
				Date_End = CASE WHEN @Date_End = '::DBNULL::' THEN NULL WHEN @Date_End IS NULL THEN Date_End ELSE @Date_End END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
