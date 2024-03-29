USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetNewStudentFeeAmount]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetNewStudentFeeAmount] (
	@Asset_Student_Transaction_ID INT, 
	@Asset_Disposition_ID INT, 
	@Is_Police_Report_Provided AS VARCHAR(30), 
	@Date_Added Date
)
  
RETURNS FLOAT 
AS  
BEGIN

	--Amount variable that will be return
	DECLARE @Amount FLOAT

	--Variable to derive amount
	DECLARE @Student_Device_Coverage_ID INT
	DECLARE @Asset_Base_Type_Code VARCHAR(100)
	DECLARE @Asset_Disposition_Code VARCHAR(100)

	--Temp Table to store record
	DECLARE @Tbl TABLE(
		Student_ID VARCHAR(20),
		School_Year INT,
		Asset_Base_Type_ID INT,
		Asset_Base_Type_Code VARCHAR(100),
		Asset_Disposition_ID INT,
		Asset_Disposition_Desc VARCHAR(100),
		Asset_Disposition_Code VARCHAR(100),
		Student_Device_Coverage_ID INT,
		Fee_Amount_Without_Coverage FLOAT,
		Fee_Amount_With_Coverage FLOAT
	)

	--Get Asset Transaction Info for the record being passed
	INSERT INTO @Tbl
	select 
		astu.Student_ID,
		astu.School_Year,
		base_type.ID as Asset_Base_Type_ID,
		base_type.Code as Asset_Base_Type_Code,
		chk_in_disp.ID as Asset_Disposition_ID,
		chk_in_disp.Name as Asset_Disposition_Desc,
		chk_in_disp.Code as Asset_Disposition_Code,
		--fsch.ID as Student_Device_Coverage_ID,
		scoverage.ID as Student_Device_Coverage_ID,
		isnull(fsch.Fee_Amount_Without_Coverage, 0) as Fee_Amount_Without_Coverage,
		isnull(fsch.Fee_Amount_With_Coverage, 0) as Fee_Amount_With_Coverage

	from Asset_Student_Transaction astu
	inner join Asset a
		on a.ID = astu.Asset_ID
	inner join CT_Asset_Type asset_Type
		on asset_Type.ID = a.Asset_Type_ID
	inner join CT_Asset_Base_Type base_Type
		on base_Type.ID = asset_Type.Asset_Base_Type_ID

	left join Student_Device_Coverage scoverage
		on scoverage.Student_ID = astu.Student_ID
		and scoverage.School_Year = astu.School_Year
		and scoverage.Is_Active = 1
		and scoverage.Date_Paid <= cast(astu.Date_Check_In as date)

	left join CT_Asset_Disposition chk_in_disp
		on chk_in_disp.ID = astu.Check_In_Disposition_ID

	left join Student_Device_Fee_Schedule fsch
		on fsch.Asset_Base_Type_ID = base_Type.ID
		and fsch.Asset_Disposition_ID = astu.Check_In_Disposition_ID
		and cast(Date_Check_In as date) between fsch.Date_Start and isnull(fsch.Date_End, getdate())

	where astu.ID = @Asset_Student_Transaction_ID
	
	--Set the variables to process
	SET @Student_Device_Coverage_ID = (SELECT a.Student_Device_Coverage_ID  from @Tbl a)
	SET @Asset_Base_Type_Code = (SELECT a.Asset_Base_Type_Code  from @Tbl a)
	SET @Asset_Disposition_Code = (SELECT a.Asset_Disposition_Code from @Tbl a)
	--Default amount fee without coverage
	SET @Amount = (SELECT a.Fee_Amount_Without_Coverage from @Tbl a)

	--Student must have coverage to get discounted amount
	--AND Discount only for base type: laptop 
	--AND Disposition: Break or Stolen
	IF @Student_Device_Coverage_ID IS NOT NULL AND @Asset_Base_Type_Code = '1' AND @Asset_Disposition_Code in ('2', '19')
		BEGIN
			--broken
			IF @Asset_Disposition_Code = '19' 
				BEGIN
					DECLARE @BrokenExist INT
					SET @BrokenExist =	isnull((
										select
											COUNT(*)
										from Asset_Student_Fee sfee
										inner join CT_Asset_Disposition disp
											on sfee.Asset_Disposition_ID = disp.ID
										inner join Student_Device_Coverage coverage
											on coverage.ID = sfee.Student_Device_Coverage_ID
										inner join @Tbl t
											on t.Student_ID = sfee.Student_ID
											and t.Asset_Base_Type_ID = sfee.Asset_Base_Type_ID
											and t.Asset_Disposition_ID = sfee.Asset_Disposition_ID
											and t.School_Year = coverage.School_Year
										where 1=1
											and sfee.Is_Active = 1
											and sfee.Student_Device_Coverage_ID is not null --only count fees that was covered
											and disp.Code in (
												'19' --Broken
											)
										group by
											t.School_Year, 
											sfee.Asset_Base_Type_ID,
											sfee.Asset_Disposition_ID
										),0)
					IF @BrokenExist = 0
					BEGIN
						SET @Amount = (SELECT a.Fee_Amount_With_Coverage from @Tbl a)
					END

				END
			
			--stolen
			IF @Asset_Disposition_Code = '2' AND @Is_Police_Report_Provided = '1'
				BEGIN
					
					DECLARE @StolenRecordExist INT
					SET @StolenRecordExist = isnull((	
												select
													count(*)
												from Asset_Student_Fee sfee
												inner join CT_Asset_Disposition disp
													on sfee.Asset_Disposition_ID = disp.ID
												inner join Student_Device_Coverage coverage
													on coverage.ID = sfee.Student_Device_Coverage_ID
												inner join @Tbl t
													on t.Student_ID = sfee.Student_ID
													and t.Asset_Base_Type_ID = sfee.Asset_Base_Type_ID
													and t.Asset_Disposition_ID = sfee.Asset_Disposition_ID
													and t.School_Year = coverage.School_Year
												where 1=1
													and sfee.Is_Active = 1
													and sfee.Student_Device_Coverage_ID is not null --only count fees that was covered
													and disp.Code in (
														'2' --stolen
													)
												group by
													t.School_Year, 
													sfee.Asset_Base_Type_ID,
													sfee.Asset_Disposition_ID
											),0)

					if @StolenRecordExist = 0
					BEGIN
						SET @Amount = (SELECT a.Fee_Amount_With_Coverage from @Tbl a)
					END
				END
		END


	RETURN @Amount

END
GO
