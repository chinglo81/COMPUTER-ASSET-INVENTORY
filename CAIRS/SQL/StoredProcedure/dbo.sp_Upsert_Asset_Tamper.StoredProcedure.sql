USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Tamper]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 1/27/2017 2:30:51 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Tamper]
	@ID AS INT,
	@Asset_ID AS INT,
	@Student_ID AS VARCHAR(20) = null,
	@Comment AS VARCHAR(max) = null,
	@Added_By_Emp_ID AS VARCHAR(11),
	@Date_Added AS VARCHAR(30),
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null,
	@Attachments AS XML
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			DECLARE @Student_School_Number VARCHAR(3) = (select SasiSchoolNum from Datawarehouse.dbo.Student where StudentId = @Student_ID)

			INSERT INTO dbo.Asset_Tamper
			(
				Asset_ID,
				Student_ID,
				Student_School_Number,
				Comment,
				Date_Processed,
				Added_By_Emp_ID,
				Date_Added,
				Modified_By_Emp_ID,
				Date_Modified
			)
			SELECT 
				@Asset_ID,
				@Student_ID,
				@Student_School_Number,
				CASE WHEN @Comment = '::DBNULL::' THEN NULL ELSE @Comment END,
				null as Date_Processed,
				@Added_By_Emp_ID,
				@Date_Added,
				CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL ELSE @Modified_By_Emp_ID END,
				CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL ELSE @Date_Modified END

			SET @returnid = SCOPE_IDENTITY()
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Tamper where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Tamper
			SET
				Comment = CASE WHEN @Comment = '::DBNULL::' THEN NULL WHEN @Comment IS NULL THEN Comment ELSE @Comment END,
				Modified_By_Emp_ID = @Modified_By_Emp_ID,
				Date_Modified = @Date_Modified
			WHERE ID = @ID

			SET @returnid = @ID

		END

	-------------------------------------------------------START Attachment---------------------------------------------------
	--Need to parse xml to insert record
	IF @Attachments IS NOT NULL
		BEGIN
			DECLARE @XML_Table AS TABLE (ItemXml XML)
			DECLARE @Attachment_Table as TABLE (
				Attachment_Type_ID INT,
				File_Type_ID INT,
				Name VARCHAR(100),
				File_Desc Varchar(1000)
			)

			INSERT INTO @XML_Table SELECT @Attachments

			INSERT INTO @Attachment_Table
			SELECT
				CAST(attachment.query('data(Attachment_Type_ID)') as VARCHAR(100)) AS Attachment_Type_ID,
				CAST(ft.id as Varchar(100)) as File_Type_ID,
				CAST(attachment.query('data(File_Name)') as VARCHAR(100)) AS Name,
				CAST(attachment.query('data(File_Desc)') as VARCHAR(1000)) AS File_Desc
			FROM  @XML_Table
			CROSS APPLY @Attachments.nodes('Attachments/Attachment') x(attachment)
			CROSS APPLY @Attachments.nodes('Attachments') y(attachments)
			left join CT_File_Type ft
				on ft.Name = CAST(attachment.query('data(File_Type)') as VARCHAR(100))

			INSERT INTO Asset_Attachment
			select 
				null, --Asset_Student_Transaction - This get set if the student is responsible for a broken asset
				@Asset_ID,
				@Student_ID,
				@returnid as Asset_Tamper_ID,
				a.Attachment_Type_ID,
				a.File_Type_ID,
				a.Name,
				a.File_Desc,
				isnull(@Added_By_Emp_ID, @Modified_By_Emp_ID),--@Emp_ID,
				isnull(@Date_Added, @Date_Modified),
				null,
				null
			from @Attachment_Table a
		END
	-------------------------------------------------------END Attachment--------------------------------------------------- 

	SELECT @returnid
END




GO
