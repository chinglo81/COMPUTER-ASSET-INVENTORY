USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Student_Coverage_Import_To_Student_Device_Coverage]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Student_Coverage_Import_To_Student_Device_Coverage] AS

	
DECLARE @TodayDate AS DATETIME = getdate()

DECLARE @Tbl_Processing_Record as TABLE(
	Student_Device_Coverage_Config_ID INT,
	Student_Device_Coverage_Import_ID INT
	
)

DECLARE @Tbl_Error_Records as Table(
	Student_Device_Coverage_Config_ID INT,
	Student_Device_Coverage_Import_ID INT,
	Message_Error VARCHAR(MAX)
)

DECLARE @Tbl_Imported_Records as Table(
	Student_Device_Coverage_Config_ID INT,
	Student_Device_Coverage_Import_ID INT
)

--Records that will be part of the processing
insert into @Tbl_Processing_Record
select 
	i.Student_Device_Coverage_Config_ID,
	i.ID as Student_Device_Coverage_Import_ID
from Student_Device_Coverage_Import i 
inner join Student_Device_Coverage_Config config 
	on config.ID = i.Student_Device_Coverage_Config_ID
where 1=1
	and config.Is_Active = 1
	and isnull(i.Is_Processed, 0) = 0

--Only process if there are records that have not been processed
IF EXISTS(SELECT 1 FROM @Tbl_Processing_Record)
	BEGIN

		--1. Student does not exist																																																																																										
		with student_not_exist as (
			select 
				i.Student_Device_Coverage_Config_ID,
				i.ID as Student_Device_Coverage_Import_ID,
				'Student not found: ' + i.Last_Name + ', ' + i.First_Name + ' (' + i.Student_ID + ')' as Message_Error
			from Student_Device_Coverage_Import i
			left join Datawarehouse.dbo.Student stu
				on stu.StudentId = i.Student_ID
			where 1=1
				and i.ID in (select Student_Device_Coverage_Import_ID from @Tbl_Processing_Record)
				and stu.StudentId is null
		),

		--2. Student already has coverage for the school year based on the date_paid
		student_has_coverage as (
			select 
				i.Student_Device_Coverage_Config_ID,
				i.ID as Student_Device_Coverage_Import_ID,
				'Student Already Imported For School Year: ' + cal.SchoolYr as Message_Error
			from Student_Device_Coverage_Config config
			inner join Student_Device_Coverage_Import i
				on i.Student_Device_Coverage_Config_ID = config.ID
			inner join Datawarehouse.dbo.School_Calendar cal
				on cal.Term = 'YE'
				and i.Date_Paid between cal.StartDate and cal.EndDate
			inner join Student_Device_Coverage sdc
				on i.Student_ID = sdc.Student_ID
				and sdc.School_Year = cal.SchoolYr

			where 1=1
				and i.ID in (select Student_Device_Coverage_Import_ID from @Tbl_Processing_Record)
		),

		--3. Match Description
		mismatch_desc as (
			select 
				i.Student_Device_Coverage_Config_ID,
				i.ID as Student_Device_Coverage_Import_ID,
				'Mismatch Description: ' + i.Description as Message_Error
			from Student_Device_Coverage_Config config
			inner join Student_Device_Coverage_Import i
				on i.Student_Device_Coverage_Config_ID = config.ID
			cross join Business_Rule br
	
			where 1=1
				and i.ID in (select Student_Device_Coverage_Import_ID from @Tbl_Processing_Record)
				and br.Code = 'Stu_Device_Coverage_Description'
				and i.Description <> br.Name
		),

		--4. Minimum payment required
		min_amount_not_paid as (
			select 
				i.Student_Device_Coverage_Config_ID,
				i.ID as Student_Device_Coverage_Import_ID,
				'Payment amount ($' + br.Name + ') not met: Paid: $' + cast(i.Payment as varchar(100)) as Message_Error
			from Student_Device_Coverage_Config config
			inner join Student_Device_Coverage_Import i
				on i.Student_Device_Coverage_Config_ID = config.ID
			cross join Business_Rule br

			where 1=1
				and i.ID in (select Student_Device_Coverage_Import_ID from @Tbl_Processing_Record)
				and br.Code = 'Stu_Device_Coverage_Min_Payment'
				and isnull(i.Payment, 0) <= cast(br.Name as float)
		),

		--5 Only process for current year
		payment_not_current_year as (
			select
				i.Student_Device_Coverage_Config_ID, 
				i.ID as Student_Device_Coverage_Import_ID,
				'Payment date (' + cast(i.Date_Paid as varchar(100)) + ') is not in the current school year (' + cal.SchoolYr + ')' as Message_Error
			from Student_Device_Coverage_Config config
			inner join Student_Device_Coverage_Import i
				on i.Student_Device_Coverage_Config_ID = config.ID
			inner join Datawarehouse.dbo.School_Calendar cal
				on cal.Term = 'YE'
				and cast(getdate() as date) between cal.StartDate and cal.EndDate

			where 1=1
				and i.ID in (select Student_Device_Coverage_Import_ID from @Tbl_Processing_Record)
				and cast(i.Date_Paid as date) not between cal.StartDate and cal.EndDate
		), 

		--Need to add validation above to group by validation
		group_validation as (
			select * from student_not_exist
			union all
			select * from student_has_coverage
			union all
			select * from mismatch_desc
			union all
			select * from min_amount_not_paid
			union all
			select * from payment_not_current_year
		),

		--Break out each message into one row
		get_single_line_message_by_id as (
			select 
				t.Student_Device_Coverage_Config_ID,
				t.Student_Device_Coverage_Import_ID,
				(
					select stuff(
					(select ';' + Message_Error
					from group_validation
					where Student_Device_Coverage_Import_ID = t.Student_Device_Coverage_Import_ID
					FOR XML PATH ('')), 1, 1, '')
				) as Error_Msg
			from group_validation t
			group by
				t.Student_Device_Coverage_Config_ID,
				t.Student_Device_Coverage_Import_ID
		)

		--Records with Errors
		insert into @Tbl_Error_Records
		select * 
		from get_single_line_message_by_id

		--Records without Errors
		insert into @Tbl_Imported_Records
		select 
			t.Student_Device_Coverage_Config_ID,
			t.Student_Device_Coverage_Import_ID 
		from @Tbl_Processing_Record t
		where t.Student_Device_Coverage_Import_ID not in (
			select Student_Device_Coverage_Import_ID from @Tbl_Error_Records
		)

		insert into Student_Device_Coverage
		select 
			import.Student_ID,
			c.Device_Fee_Type_ID,
			cal.SchoolYr as School_Year,
			'SYSTEM' as Added_By_Emp_ID,
			@TodayDate,
			1 as Is_Active
		from Student_Device_Coverage_Import import
		inner join Student_Device_Coverage_Config c
			on import.Student_Device_Coverage_Config_ID = c.ID
		inner join Datawarehouse.dbo.School_Calendar cal
			on cal.Term = 'YE'
			and import.Date_Paid between cal.StartDate and cal.EndDate
		where import.ID in (
			select Student_Device_Coverage_Import_ID from @Tbl_Imported_Records
		)

		--Update records submitted successfully
		update Student_Device_Coverage_Import
			set 
				Is_Processed = 1,
				Is_Imported = 1,
				Date_Imported = @TodayDate,
				Comment = 'Successfully Imported'
		from Student_Device_Coverage_Import i 
		inner join @Tbl_Imported_Records success
			on success.Student_Device_Coverage_Import_ID = i.ID

		--Update records with error messages
		update Student_Device_Coverage_Import
			set 
				Is_Processed = 1,
				Is_Imported = 0,
				Date_Imported = @TodayDate,
				Comment = error.Message_Error
		from Student_Device_Coverage_Import i 
		inner join @Tbl_Error_Records error
			on error.Student_Device_Coverage_Import_ID = i.ID
	

		--Update Config Total Count
		update Student_Device_Coverage_Config
			SET 
				Last_Import_Count_Total = tbl.Last_Import_Count_Total,
				Last_Import_Count_Error = tbl.Last_Import_Count_Error,
				Last_Import_Count_Success = tbl.Last_Import_Count_Success,
				Last_Import_Count_Not_Processed = tbl.Last_Import_Not_Processed,
				Last_Import_Status = 'Processed', 
				Date_Last_Import = @TodayDate
	
		from Student_Device_Coverage_Config config
		inner join (
			select 
				c.ID,
				count(import.ID) as Last_Import_Count_Total,
				sum(case when isnull(import.Is_Processed, 0) = 1 and isnull(import.Is_Imported, 0) = 0 then 1 else 0 end) as Last_Import_Count_Error,
				sum(case when isnull(import.Is_Processed, 0) = 1 and isnull(import.Is_Imported, 0) = 1 then 1 else 0 end) as Last_Import_Count_Success,
				sum(case when isnull(import.Is_Processed, 0) = 0 and import.ID is not null then 1 else 0 end) as Last_Import_Not_Processed
			from Student_Device_Coverage_Config c
			left join Student_Device_Coverage_Import import
				on import.Student_Device_Coverage_Config_ID = c.ID
			where import.ID in (
				select a.Student_Device_Coverage_Import_ID from @Tbl_Processing_Record a
			)
			group by
				c.ID
		) tbl
			on tbl.ID = config.ID

	END
ELSE
	BEGIN
		update Student_Device_Coverage_Config
			SET 
				Last_Import_Count_Total = 0,
				Last_Import_Count_Error = 0,
				Last_Import_Count_Success = 0,
				Last_Import_Count_Not_Processed = 0,
				Last_Import_Status = CASE WHEN isnull(Last_Import_Status, '') = '' then 'No Data Found' else Last_Import_Status + ';No Data Found' end,
				Date_Last_Import = @TodayDate
		where Is_Active = 1
	END

	



GO
