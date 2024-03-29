USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_App_User_Preference]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 1/27/2017 10:12:51 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_App_User_Preference]
	@Emp_ID AS VARCHAR(11), 
	@App_Preference_Type_Code AS VARCHAR(100),
	@Preference_Value AS VARCHAR(100),
	@returnid AS INT = NULL OUTPUT
AS
BEGIN
	SET @returnid = -1

	DECLARE @App_Preference_Type_ID AS INT = ISNULL((SELECT ID FROM App_Preference_Type where Code = @App_Preference_Type_Code), -1)

	--Only perform update if @App_Preference_Type_ID Exist
	IF @App_Preference_Type_ID <> -1
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements
		SET NOCOUNT ON; 

		DECLARE @App_User_Preference_ID AS INT = ISNULL((SELECT ID FROM App_User_Preference WHERE App_Preference_Type_ID = @App_Preference_Type_ID and Emp_ID = @Emp_ID), -1)

		IF @App_User_Preference_ID = -1
			BEGIN
				--Insert
				INSERT INTO App_User_Preference SELECT @App_Preference_Type_ID, @Emp_ID, @Preference_Value
				SET @returnid = SCOPE_IDENTITY()
			END
		ELSE
			BEGIN
				--Update
				UPDATE App_User_Preference
					SET Preference_Value = @Preference_Value
				WHERE ID = @App_User_Preference_ID
				SET @returnid = @App_User_Preference_ID
			END
	END

	Select @returnid
END




GO
