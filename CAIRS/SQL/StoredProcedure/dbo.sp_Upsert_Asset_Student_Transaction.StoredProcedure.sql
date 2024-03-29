USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Student_Transaction]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 2/13/2017 7:15:40 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Student_Transaction]
	@ID AS INT,
	@Asset_ID AS INT,
	@Student_ID AS VARCHAR(20),
	@Student_School_Number AS VARCHAR(3),
	@School_Year AS INT,
	@Check_Out_Asset_Condition_ID AS VARCHAR(30) = null,
	@Check_Out_By_Emp_ID AS VARCHAR(11) ,
	@Date_Check_Out AS VARCHAR(30),
	@Check_In_Type_ID as VARCHAR(30) = null,
	@Check_In_Asset_Condition_ID AS VARCHAR(30) = null,
	@Check_In_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Check_In AS VARCHAR(30) = null,
	@Comment AS VARCHAR(MAX) = null,
	@Check_In_Disposition_ID AS VARCHAR(30) = null,
	@Found_Date AS VARCHAR(30) = null,
	@Found_Disposition_ID AS VARCHAR(30) = null,
	@Found_Asset_Condition_ID AS VARCHAR(30) = null,
	@Stu_Responsible_For_Damage AS VARCHAR(30) = null,
	@Is_Police_Report_Provided AS VARCHAR(30) = null,
	@returnid AS INT = null OUTPUT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			DECLARE @Asset_Site_ID AS INT = (SELECT Site_ID FROM Asset_Site_Mapping where Asset_ID = @Asset_ID)

			INSERT INTO dbo.Asset_Student_Transaction
			(
				Asset_ID,
				Asset_Site_ID,
				Student_ID,
				Student_School_Number,
				School_Year,
				Check_Out_Asset_Condition_ID,
				Check_Out_By_Emp_ID,
				Date_Check_Out,
				Check_In_Type_ID,
				Check_In_Asset_Condition_ID,
				Check_In_By_Emp_ID,
				Date_Check_In,
				Comment,
				Check_In_Disposition_ID,
				Found_Date,
				Found_Disposition_ID,
				Found_Asset_Condition_ID,
				Stu_Responsible_For_Damage,
				Is_Police_Report_Provided
			)
			SELECT 
				@Asset_ID,
				@Asset_Site_ID,
				@Student_ID,
				@Student_School_Number,
				@School_Year,
				CASE WHEN @Check_Out_Asset_Condition_ID = '::DBNULL::' THEN NULL ELSE @Check_Out_Asset_Condition_ID END,
				@Check_Out_By_Emp_ID,
				@Date_Check_Out,
				CASE WHEN @Check_In_Type_ID = '::DBNULL::' THEN NULL ELSE @Check_In_Type_ID END,
				CASE WHEN @Check_In_Asset_Condition_ID = '::DBNULL::' THEN NULL ELSE @Check_In_Asset_Condition_ID END,
				CASE WHEN @Check_In_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Check_In_By_Emp_ID END,
				CASE WHEN @Date_Check_In = '::DBNULL::' THEN NULL ELSE @Date_Check_In END,
				CASE WHEN @Comment = '::DBNULL::' THEN NULL ELSE @Comment END,
				CASE WHEN @Check_In_Disposition_ID = '::DBNULL::' THEN NULL ELSE @Check_In_Disposition_ID END,
				CASE WHEN @Found_Date = '::DBNULL::' THEN NULL ELSE @Found_Date END,
				CASE WHEN @Found_Disposition_ID = '::DBNULL::' THEN NULL ELSE @Found_Disposition_ID END,
				CASE WHEN @Found_Asset_Condition_ID = '::DBNULL::' THEN NULL ELSE @Found_Asset_Condition_ID END,
				CASE WHEN @Stu_Responsible_For_Damage = '::DBNULL::' THEN NULL ELSE @Stu_Responsible_For_Damage END,
				CASE WHEN @Is_Police_Report_Provided = '::DBNULL::' THEN NULL ELSE @Is_Police_Report_Provided END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Student_Transaction where ID = @ID)
		BEGIN

			UPDATE dbo.Asset_Student_Transaction
				SET
					/*Should not be editable
					Asset_ID = CASE WHEN @Asset_ID IS NULL THEN Asset_ID ELSE @Asset_ID END,
					Student_ID = CASE WHEN @Student_ID IS NULL THEN Student_ID ELSE @Student_ID END,
					Student_School_Number = CASE WHEN @Student_School_Number IS NULL THEN Student_School_Number ELSE @Student_School_Number END,
					School_Year = CASE WHEN @School_Year IS NULL THEN School_Year ELSE @School_Year END,
					Check_Out_Asset_Condition_ID =	CASE WHEN @Check_Out_Asset_Condition_ID = '::DBNULL::'	THEN NULL WHEN @Check_Out_Asset_Condition_ID IS NULL THEN Check_Out_Asset_Condition_ID		ELSE @Check_Out_Asset_Condition_ID END,
					Check_Out_By_Emp_ID =			CASE WHEN @Check_Out_By_Emp_ID = '::DBNULL::'			THEN NULL WHEN @Check_Out_By_Emp_ID IS NULL THEN Check_Out_By_Emp_ID						ELSE @Check_Out_By_Emp_ID END,
					Date_Check_Out =				CASE WHEN @Date_Check_Out = '::DBNULL::'				THEN NULL WHEN @Date_Check_Out IS NULL THEN Date_Check_Out									ELSE @Date_Check_Out END,
					*/
					Check_In_Type_ID =				CASE WHEN @Check_In_Type_ID = '::DBNULL::'				THEN NULL WHEN @Check_In_Type_ID IS NULL THEN Check_In_Type_ID								ELSE @Check_In_Type_ID END,
					Check_In_Asset_Condition_ID =	CASE WHEN @Check_In_Asset_Condition_ID = '::DBNULL::'	THEN NULL WHEN @Check_In_Asset_Condition_ID IS NULL THEN Check_In_Asset_Condition_ID		ELSE @Check_In_Asset_Condition_ID END,
					Check_In_By_Emp_ID =			CASE WHEN @Check_In_By_Emp_ID = '::DBNULL::'			THEN NULL WHEN @Check_In_By_Emp_ID IS NULL THEN Check_In_By_Emp_ID							ELSE @Check_In_By_Emp_ID END,
					--Don't update the date if there is one that already exist
					Date_Check_In =					CASE 
														WHEN LEN(Date_Check_In) > 0 OR @Date_Check_In IS NULL THEN Date_Check_In --Update to itself if already exist
														WHEN @Date_Check_In = '::DBNULL::' THEN NULL								
														ELSE @Date_Check_In 
													END,
					Comment =						CASE WHEN @Comment = '::DBNULL::'						THEN NULL WHEN @Comment IS NULL THEN Comment												ELSE @Comment END,
					Check_In_Disposition_ID =		CASE WHEN @Check_In_Disposition_ID = '::DBNULL::'		THEN NULL WHEN @Check_In_Disposition_ID IS NULL THEN Check_In_Disposition_ID				ELSE @Check_In_Disposition_ID END,
					Found_Date =					CASE WHEN @Found_Date = '::DBNULL::'					THEN NULL WHEN @Found_Date IS NULL THEN Found_Date											ELSE @Found_Date END,
					Found_Disposition_ID =			CASE WHEN @Found_Disposition_ID = '::DBNULL::'			THEN NULL WHEN @Found_Disposition_ID IS NULL THEN Found_Disposition_ID						ELSE @Found_Disposition_ID END,
					Found_Asset_Condition_ID =		CASE WHEN @Found_Asset_Condition_ID = '::DBNULL::'		THEN NULL WHEN @Found_Asset_Condition_ID IS NULL THEN Found_Asset_Condition_ID				ELSE @Found_Asset_Condition_ID END,
					Stu_Responsible_For_Damage =	CASE WHEN @Stu_Responsible_For_Damage = '::DBNULL::'	THEN NULL WHEN @Stu_Responsible_For_Damage IS NULL THEN Stu_Responsible_For_Damage			ELSE @Stu_Responsible_For_Damage END,
					Is_Police_Report_Provided =		CASE WHEN @Is_Police_Report_Provided = '::DBNULL::'		THEN NULL WHEN @Is_Police_Report_Provided IS NULL THEN Is_Police_Report_Provided			ELSE @Is_Police_Report_Provided END

			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END



GO
