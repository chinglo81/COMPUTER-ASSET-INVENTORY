USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Submit_Asset_Temp_To_Asset]    Script Date: 2/3/2017 10:35:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery42.sql|7|0|C:\Users\lo.c\AppData\Local\Temp\~vsD127.sql
-- Batch submitted through debugger: SQLQuery30.sql|7|0|C:\Users\lo.c\AppData\Local\Temp\~vs200A.sql
-- =============================================
-- Create date: 1/19/2017 8:45:41 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Submit_Asset_Temp_To_Asset]
	@Asset_Temp_Header_ID AS INT,
	@Date_Submit AS VARCHAR(100),
	@Submitted_By_Emp_ID AS VARCHAR(11)
AS

BEGIN 
	DECLARE @Message as VARCHAR(MAX)
	SET @Message = 'SUCCESS'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 

	IF EXISTS (Select 1 from dbo.Asset_Temp_Header where ID = @Asset_Temp_Header_ID)
		BEGIN
			--Validate before loading
			DECLARE @Validate as int 
			SET @Validate = (
				select count(*) 
				from ( 
					--Check for duplicate tag id within batch.
					select 
						1 as Exist
					from Asset_Temp_Detail d
					where d.Asset_Temp_Header_ID = @Asset_Temp_Header_ID
					group by
						d.Tag_ID
					having count(*) > 1

					union all

					--check if any of the tag id in the batch already exist in the tags table
					select 
						1 as Exist
					from Asset_Temp_Header hdr
					inner join Asset_Temp_Detail det
						on det.Asset_Temp_Header_ID = hdr.ID
					inner join Asset a
						on a.Tag_ID = det.Tag_ID
						and a.Is_Active = 1
					where hdr.ID = @Asset_Temp_Header_ID
				) tbl
			)

			--0 Means it pass validation
			IF @Validate = 0 
				BEGIN																																																																																		BEGIN
					--Update Asset Temp Header Table 
					UPDATE dbo.Asset_Temp_Header
					SET
						Has_Submit = 1,
						Date_Submit = @Date_Submit,
						Submitted_By_Emp_ID = @Submitted_By_Emp_ID
					WHERE ID = @Asset_Temp_Header_ID

					-----------------------------------------------------
					--START Cursor insert one record at a time
					-----------------------------------------------------
					DECLARE @Cursor CURSOR
					DECLARE @New_Asset_ID as int
					--Variables
					DECLARE @Asset_Site_ID as int
					DECLARE @Asset_Assignment_Type_ID as int
					DECLARE @Asset_Condition_ID as int
					DECLARE @Asset_Disposition_ID as int
					DECLARE @Asset_Type_ID as int
					DECLARE @Bin_ID as int
					DECLARE @Date_Purchased as varchar(100)
					DECLARE @Is_Leased as varchar(100)
					DECLARE @Serial_Number as varchar(100)
					DECLARE @Tag_ID as VARCHAR(100)

				SET @Cursor = CURSOR FAST_FORWARD 
				FOR
					select 
						hdr.Asset_Site_ID,
						det.Asset_Assignment_Type_ID,
						det.Asset_Condition_ID,
						det.Asset_Disposition_ID,
						det.Asset_Type_ID,
						det.Bin_ID,
						det.Date_Purchased,
						det.Is_Leased,
						det.Serial_Number,
						det.Tag_ID
					from Asset_Temp_Header hdr
					inner join Asset_Temp_Detail det
						on det.Asset_Temp_Header_ID = hdr.ID
					where hdr.ID = @Asset_Temp_Header_ID
					OPEN @Cursor 
					FETCH NEXT FROM @Cursor 

					INTO @Asset_Site_ID, @Asset_Assignment_Type_ID, @Asset_Condition_ID, @Asset_Disposition_ID, @Asset_Type_ID, @Bin_ID, @Date_Purchased, @Is_Leased, @Serial_Number, @Tag_ID

					WHILE @@FETCH_STATUS = 0 
					BEGIN 
						--Insert into Asset Table
						EXEC dbo.sp_Upsert_Asset	-1,
													@Tag_ID,
													@Asset_Disposition_ID,
													@Asset_Condition_ID,
													@Asset_Type_ID,
													@Asset_Assignment_Type_ID,
													@Serial_Number,
													@Date_Purchased,
													@Is_Leased,
													1, --Is Active
													@Submitted_By_Emp_ID, --Added_By
													@Date_Submit, --Date_Added
													@Submitted_By_Emp_ID, -- Modifed_By
													@Date_Submit, --Date Modifed
													@New_Asset_ID OUTPUT
					
						--Create Asset Site Mapping
						EXEC dbo.sp_Upsert_Asset_Site_Mapping	-1,
																@New_Asset_ID,
																@Asset_Site_ID,
																@Submitted_By_Emp_ID,
																@Date_Submit
					
						--Create Asset Bin Mapping If Exist. Not a required parameter
						IF @Bin_ID IS NOT NULL
							BEGIN
								EXEC dbo.sp_Upsert_Asset_Bin_Mapping	-1,
																		@Bin_ID,
																		@New_Asset_ID,
																		@Date_Submit,
																		@Submitted_By_Emp_ID
							END
						FETCH NEXT FROM @Cursor
						INTO @Asset_Site_ID, @Asset_Assignment_Type_ID, @Asset_Condition_ID, @Asset_Disposition_ID, @Asset_Type_ID, @Bin_ID, @Date_Purchased, @Is_Leased, @Serial_Number, @Tag_ID
					END
					-----------------------------------------------------
					--END Cursor insert one record at a time
					-----------------------------------------------------
				END
				END
			ELSE
				BEGIN
					SET @Message = 'Validation Error: Duplicate TAG IDs'
				END
		END
	ELSE
		BEGIN
			SET @Message = 'Header ID' + CAST(@Asset_Temp_Header_ID AS VARCHAR(100)) + ' does not exist.'
		END
	
	SELECT @Message as Message
END



GO
