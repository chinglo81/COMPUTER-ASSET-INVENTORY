USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Import_Record_1_Validate]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Import_Record_1_Validate] 
(
	@DateTime AS DateTime
)

AS
	DECLARE @Tbl_Error as TABLE(
		Import_Record_ID INT,
		Error_Msg Varchar(MAX)
	)
	;

	--NOTE: Validation to verify columns are correct is being done in the CAIRS_Jobs Console App in the Utilities.cs file under method ValidateRequireFields(DataTable dt, string import_config_id)

	-- Student does not exist																																																																																										
	with student_not_exist as (
		select distinct
			i.ID as Import_Record_ID,
			'Student not found: ' + i.Last + ', ' + i.First + ' (' + i.Student_ID + ')' as Message_Error
		from Import_Record i
		left join Datawarehouse.dbo.Student stu
			on stu.StudentId = i.Student_ID
		where 1=1
			and stu.StudentId is null
	),

	-- Invalid Type
	mismatch_desc as (
		select distinct
			i.ID as Import_Record_ID,
			'Invalid Type: ' + i.Import_Type_Desc as Message_Error
		from Import_Record i
		where i.Import_Type_ID = -1
			
	),

	-- Match on Price
	min_amount_not_paid as (
		select distinct
			i.ID as Import_Record_ID,
			'Invalid Price ($' + cast(i.Price as varchar(100)) + ') does not match $' + cast(itype.Price as varchar(100)) + ' (' + itype.Name + ')'  as Message_Error
		from Import_Record i
		inner join Import_Type itype
			on itype.ID = i.Import_Type_ID
			and i.Import_Type_ID <> -1
		where 1=1
			and isnull(i.Price, 0) <> isnull(itype.Price, 0)
	),

	--Only process for current year
	payment_not_current_year as (
		select distinct
			i.ID as Import_Record_ID,
			'Invalid date (' + cast(i.Date as varchar(100)) + ') is not in the current school year (' + cal.SchoolYr + ')' as Message_Error
		from Import_Record i
		inner join Datawarehouse.dbo.School_Calendar cal
			on cal.Term = 'YE'
			and cast(getdate() as date) between cal.StartDate and cal.EndDate

		where 1=1
			and cast(i.Date as date) not between cal.StartDate and cal.EndDate
	), 

	-- Student already has coverage for the current school year based on the date 
	-- NOTE: Only for Limited Technology Coverage Fee
	student_has_coverage as (
		select distinct
			i.ID as Import_Record_ID,
			'Student Already Imported For School Year: ' + cal.SchoolYr + ' (Student_Device_Coverage ID: ' + cast(sdc.ID as varchar(100)) + ')' as Message_Error
		from Import_Record i
		inner join Datawarehouse.dbo.School_Calendar cal
			on cal.Term = 'YE'
			and i.Date between cal.StartDate and cal.EndDate
		inner join Student_Device_Coverage sdc
			on i.Student_ID = sdc.Student_ID
			and sdc.School_Year = cal.SchoolYr
		where 1=1
			and i.Import_Type_ID = 1 --Limited Technology Coverage Fee
	),

	duplicate_payment as (
		select distinct
			r.ID as Import_Record_ID,
			'Duplicate Payment Record' as Message_Error
		from Import_Record r
		inner join Import_Record_Payment p
			on p.Student_ID = r.Student_ID
			and p.Import_Type_ID = r.Import_Type_ID
			and p.Price = r.Price
			and p.Payments = r.Payments
			and p.Date = r.Date 
	),


	--Need to add validation above to group by validation
	group_validation as (
		select * from student_not_exist
		union all
		select * from mismatch_desc
		union all
		select * from min_amount_not_paid
		union all
		select * from payment_not_current_year
		union all
		select * from student_has_coverage
		union all
		select * from duplicate_payment
	),

	--Break out each message into one row
	get_single_line_message_by_id as (
		select 
			t.Import_Record_ID,
			(
				select stuff(
				(select ';' + Message_Error
				from group_validation
				where Import_Record_ID = t.Import_Record_ID
				FOR XML PATH ('')), 1, 1, '')
			) as Error_Msg
		from group_validation t
		group by
			t.Import_Record_ID
	)

	--Insert error into temp table
	INSERT INTO @Tbl_Error Select * from get_single_line_message_by_id

	--Update Import_Record with errors
	update Import_Record
		set 
			Is_Processed = 1,
			Is_Imported = 0,
			Comment = err.Error_Msg,
			Date_Imported = @DateTime

	from Import_Record r
	inner join @Tbl_Error err
		on r.ID = err.Import_Record_ID
	



GO
