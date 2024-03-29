USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Upsert_Asset_Student_Fee]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 3/10/2017 2:22:33 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Upsert_Asset_Student_Fee]
	@ID AS INT,
	@Student_Device_Coverage_ID AS INT,
	@Asset_Student_Transaction_ID AS INT,
	@Student_ID AS VARCHAR(20),
	@Asset_ID AS INT,
	@Asset_Base_Type_ID AS INT,
	@Asset_Type_ID AS INT,
	@Check_In_Type_Code AS VARCHAR(10),
	@Asset_Disposition_ID AS INT,
	@Asset_Disposition_Desc AS VARCHAR(100) ,
	@Is_Police_Report_Provided AS VARCHAR(30),
	@Owed_Amount AS FLOAT = null,
	@Date_Processed_School_Msg AS VARCHAR(30),
	@Date_Processed_Fee AS VARCHAR(30),
	@Comment as VARCHAR(MAX) = null,
	@Added_By_Emp_ID AS VARCHAR(11),
	@Date_Added AS VARCHAR(30),
	@Modified_By_Emp_ID AS VARCHAR(11) = null,
	@Date_Modified AS VARCHAR(30) = null,
	@returnid as int = null OUTPUT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	IF @ID = -1 -- -1 Means Insert 
		BEGIN
			--Assess Refund for Found Check In Type
			--Found Check In Type and a fee already exist
			DECLARE @Previous_Asset_Student_Fee_ID AS INT
			
			--Check to see if there was a previous (lost or stolen or not returned) fee for this transaction
			SET @Previous_Asset_Student_Fee_ID = ISNULL(
													(
														SELECT ID 
														FROM dbo.Asset_Student_Fee 
														WHERE 1=1 
															AND Asset_Student_Transaction_ID = @Asset_Student_Transaction_ID 
															AND Asset_Disposition_ID in (
																2, --Stolen 
																4, --Lost
																1010 --Not Returned
															)
															AND Is_Active = 1
													)
													, 0)
			
			
			
			--Refund based on the rule
			--If Check in type in ("Found", "Return") and previously report as "Lost or Stolen or Not Returned"
			IF @Check_In_Type_Code in ('4', '6') AND @Previous_Asset_Student_Fee_ID <> 0
			BEGIN
				DECLARE @Today AS DATE = GETDATE()

				insert into Asset_Student_Fee
				select 
					fee.Student_Device_Coverage_ID,
					fee.Asset_Student_Transaction_ID,
					fee.Student_ID,
					fee.Asset_ID,
					fee.Asset_Base_Type_ID,
					fee.Asset_Type_ID,
					fee.Disp_ID,
					fee.Disp_Desc,
					0 as Is_Police_Report_Provided,
					CASE 
						WHEN @Today between fee.date_start and fee.date_end and fee.Owed_Amount <> 0 then
							-fee.Owed_Amount 
						Else
							0
					END as Owed_Amt,
					NULL as Date_Processed_School_Msg,
					NULL as Date_Processed_Fee,
					NULL as Is_Student_Active_When_Processed_Fee,
					CASE 
						WHEN @Today between fee.date_start and fee.date_end then
							'Refund amount previously charged'
						Else
							'Refund was not provided because device was returned after the checked out school year'
					END as Comment,
					@Added_By_Emp_ID as Added_By_Emp_ID,
					@Date_Added as Date_Added,
					null as Modified_By_Emp_ID,
					null as Date_Modified,
					1 as Is_Active,
					null as Deactivated_Reason,
					null as Deactivated_Date,
					null as Deactivated_Emp_ID

				from (
					select 
						ast.School_Year,
						f.*,
						disp.ID as Disp_ID,
						disp.Name as Disp_Desc,
						isnull(a.Date_Purchased, @Today) as date_start,
						isnull(DATEADD(day, a.Leased_Term_Days, a.Date_Purchased), @Today) as date_end
					from Asset_Student_Fee f
					inner join Asset_Student_Transaction ast
						on ast.id = f.Asset_Student_Transaction_ID 
					inner join Asset a
						on a.ID = ast.Asset_ID
					cross join CT_Asset_Disposition disp
					where 1=1
						and f.ID = @Previous_Asset_Student_Fee_ID
						and disp.ID = case 
										when @Check_In_Type_Code = '4' then 10 --Found
										when @Check_In_Type_Code = '6' then 1009 --Returned
										else 0 
									   end
						and f.Is_Active = 1
				) fee

			END

			--1. Only create a fee if the disposition is one of the ones in the fee schedule
			IF EXISTS( 
				SELECT 1 
				FROM Student_Device_Fee_Schedule sch 
				WHERE 1=1
					and sch.Asset_Disposition_ID = @Asset_Disposition_ID 
					and cast(@Date_Added as Date) between sch.Date_Start and isnull(sch.Date_End, cast(getdate() as date))
			)
			BEGIN
				DECLARE @Owed_Amt AS FLOAT
				DECLARE @Student_Already_Charged AS INT

				SET @Student_Already_Charged = ISNULL(
												(
													select 1
													from Asset_Student_Fee f
													where 1=1
														and f.Asset_Student_Transaction_ID = @Asset_Student_Transaction_ID
														and f.Asset_Disposition_ID in (
															2,		--Stolen
															4,		--Lost
															10,		--Found
															1010,	--Not Returned
															1009	--Returned
														)
														and f.Is_Active = 1
													group by
														f.Asset_Student_Transaction_ID
													having sum(f.Owed_Amount) > 0
												)
												, 0
											)
				
				--If the asset is broken, check to see if the student has already been charged a lost or stolen fee. This is to prevent double charging
				IF @Asset_Disposition_ID = 1005 AND @Student_Already_Charged = 1
					BEGIN
						SET @Owed_Amt = 0;
						SET @Comment = 'Student already charged for this asset as (Lost or Stolen or Not Returned). ' + @Comment
					END
				ELSE
					BEGIN
						SET @Owed_Amt = isnull(dbo.GetNewStudentFeeAmount(@Asset_Student_Transaction_ID, @Asset_Disposition_ID, @Is_Police_Report_Provided, @Date_Added), 0)
					END
				 

				INSERT INTO dbo.Asset_Student_Fee
				(
					Student_Device_Coverage_ID,
					Asset_Student_Transaction_ID,
					Student_ID,
					Asset_ID,
					Asset_Base_Type_ID,
					Asset_Type_ID,
					Asset_Disposition_ID,
					Asset_Disposition_Desc,
					Is_Police_Report_Provided,
					Owed_Amount,
					Date_Processed_School_Msg,
					Date_Processed_Fee,
					Comment,
					Added_By_Emp_ID,
					Date_Added,
					Modified_By_Emp_ID,
					Date_Modified,
					Is_Active
				)
				select 
					scoverage.ID as Student_Device_Coverage_ID,
					astu.ID as Asset_Student_Transaction_ID,
					astu.Student_ID,
					astu.Asset_ID,
					asset_type.Asset_Base_Type_ID,
					a.Asset_Type_ID,
					disp.ID as Asset_Disposition_ID,
					disp.Name as Asset_Disposition_Desc,
					isnull(@Is_Police_Report_Provided, 0) as Is_Police_Report_Provided, --Is_Police_Report_Provided
					@Owed_Amt as Owed_Amount, --Owed_Amount
					NULL, --Date_Processed_School_Msg
					NULL, --Date_Processed_Fee
					@Comment as Comment,
					@Added_By_Emp_ID,--Added_By_Emp_ID
					@Date_Added,--Date_Added
					null,--Modified_By_Emp_ID
					null,--Date_Modified
					1 as Is_Active

				from Asset_Student_Transaction astu
				inner join Asset a
					on a.ID = astu.Asset_ID
				inner join CT_Asset_Type asset_Type
					on asset_Type.ID = a.Asset_Type_ID
				inner join CT_Asset_Base_Type base_Type
					on base_Type.ID = asset_Type.Asset_Base_Type_ID
				inner join CT_Asset_Disposition disp
					on disp.ID = astu.Check_In_Disposition_ID

				left join Student_Device_Coverage scoverage
					on scoverage.Student_ID = astu.Student_ID
					and scoverage.School_Year = astu.School_Year
					and scoverage.Is_Active = 1
					and scoverage.Date_Paid <= cast(astu.Date_Check_In as date) --Coverage only allow for devices on or after the paid date

				where astu.ID = @Asset_Student_Transaction_ID

				--Set the return id to the newly created record
				SET @returnid = SCOPE_IDENTITY()
			END
		END
	ELSE -- Edit Existing 
		IF EXISTS (Select 1 from dbo.Asset_Student_Fee where ID = @ID)
		BEGIN
			UPDATE dbo.Asset_Student_Fee
			SET
				Student_Device_Coverage_ID = CASE WHEN @Student_Device_Coverage_ID IS NOT NULL THEN @Student_Device_Coverage_ID ELSE Student_Device_Coverage_ID END,
				Asset_Student_Transaction_ID = CASE WHEN @Asset_Student_Transaction_ID IS NOT NULL THEN @Asset_Student_Transaction_ID ELSE Asset_Student_Transaction_ID END,
				Student_ID = CASE WHEN @Student_ID IS NOT NULL THEN @Student_ID ELSE Student_ID END,
				Asset_ID = CASE WHEN @Asset_ID IS NOT NULL THEN @Asset_ID ELSE Asset_ID END,
				Asset_Base_Type_ID = CASE WHEN @Asset_Base_Type_ID IS NOT NULL THEN @Asset_Base_Type_ID ELSE Asset_Base_Type_ID END,
				Asset_Type_ID = CASE WHEN @Asset_Type_ID IS NOT NULL THEN @Asset_Type_ID ELSE Asset_Type_ID END,
				Asset_Disposition_ID = CASE WHEN @Asset_Disposition_ID IS NOT NULL THEN @Asset_Disposition_ID ELSE Asset_Disposition_ID END,
				Asset_Disposition_Desc = CASE WHEN @Asset_Disposition_Desc IS NOT NULL THEN @Asset_Disposition_Desc ELSE Asset_Disposition_Desc END,
				Is_Police_Report_Provided = CASE WHEN @Is_Police_Report_Provided IS NOT NULL THEN @Is_Police_Report_Provided ELSE Is_Police_Report_Provided END,
				Date_Processed_School_Msg = CASE WHEN @Date_Processed_School_Msg IS NOT NULL THEN @Date_Processed_School_Msg ELSE Date_Processed_School_Msg END,
				Date_Processed_Fee = CASE WHEN @Date_Processed_Fee IS NOT NULL THEN @Date_Processed_Fee ELSE Date_Processed_Fee END,
				Owed_Amount = CASE WHEN @Owed_Amount = '::DBNULL::' THEN NULL WHEN @Owed_Amount IS NULL THEN Owed_Amount ELSE @Owed_Amount END,
				Modified_By_Emp_ID = CASE WHEN @Modified_By_Emp_ID = '::DBNULL::' THEN NULL WHEN @Modified_By_Emp_ID IS NULL THEN Modified_By_Emp_ID ELSE @Modified_By_Emp_ID END,
				Date_Modified = CASE WHEN @Date_Modified = '::DBNULL::' THEN NULL WHEN @Date_Modified IS NULL THEN Date_Modified ELSE @Date_Modified END
			WHERE ID = @ID

			SET @returnid = @ID

		END
		SELECT @returnid
END




GO
