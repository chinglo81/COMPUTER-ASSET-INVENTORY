USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Import_Record_2_Student_Device_Coverage]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Import_Record_2_Student_Device_Coverage] 
(
	@DateTime AS DateTime
)
AS	
	--Table for list of records that will be used to insert into student coverage
	DECLARE @Tbl_Processing_Record as TABLE(
		Import_Record_ID INT
	)

	--insert records processing
	insert into @Tbl_Processing_Record
	select 
		i.ID
	from Import_Record i 
	where 1=1
		and i.Import_Type_ID = 1 --Only student coverage
		and i.Is_Processed is null --Only records that have not been processed

	--Insert Records
	insert into Student_Device_Coverage
	
	select 
		import.Student_ID,
		c.Device_Fee_Type_ID,
		cal.SchoolYr as School_Year,
		min(t.Import_Record_ID), -- there may be duplicates
		min(import.Date),
		'SYSTEM' as Added_By_Emp_ID,
		@DateTime,
		1 as Is_Active

	from @Tbl_Processing_Record t
	inner join Import_Record import
		on import.ID = t.Import_Record_ID
	inner join Import_Config c
		on import.Import_Config_ID = c.ID
	inner join Datawarehouse.dbo.School_Calendar cal
		on cal.Term = 'YE'
		and import.Date between cal.StartDate and cal.EndDate

	where import.ID in (
		select Import_Record_ID from @Tbl_Processing_Record
	)

	group by
		import.Student_ID,
		c.Device_Fee_Type_ID,
		cal.SchoolYr

	--Update records submitted successfully
	update Import_Record
		set 
			Is_Processed = 1,
			Is_Imported = 1,
			Date_Imported = @DateTime,
			Comment = 'Successfully Imported'
	from Import_Record i 
	where i.ID in (
		select * from @Tbl_Processing_Record
	)

		

	

GO
