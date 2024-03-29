USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Student_With_Coverage]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Student_With_Coverage]
		@School_List as varchar(MAX), 
		@Grade_List as VARCHAR(MAX),
		@Active as VARCHAR(10),
		@Paid_LTC as VARCHAR(10),
		@School_Year int
AS

--Temp table that holds the list of schools process
DECLARE @Tbl_School_List AS TABLE(
	School_Number VARCHAR(3)
)
--Temp table that holds the list of grades process
DECLARE @Tbl_Grade_List AS TABLE(
	Grade VARCHAR(2)
)

--Temp table that holds the list of status
DECLARE @Tbl_Student_Status as TABLE(
	Student_Status VARCHAR(1)
)

--Insert paramter into temp tables
INSERT INTO @Tbl_School_List
SELECT * FROM dbo.CSVToTable(@School_List,',')

INSERT INTO @Tbl_Grade_List
SELECT * FROM dbo.CSVToTable(@Grade_List,',')
;

INSERT INTO @Tbl_Student_Status
SELECT * FROM dbo.CSVToTable(@Active,',')
;

select
	sch.ShortName as Student_School,
	stu.StudentID as Student_ID,
	Datawarehouse.dbo.getStudentNameById(stu.StudentID) as Student_Name,
	stu.Grade,
	stu.InstructionalSettingDesc,
	dbo.FormatDateTime(stu.EnrollmentDate,'MM/DD/YYYY') as EnrollmentDate,
	dbo.FormatDateTime(stu.LeaveDate,'MM/DD/YYYY') as LeaveDate,
	c.Date_Paid,
	cal.SchoolYear,
	case when stu.StudentStatus is null then 'Active' else 'Inactive' end as Student_Status,
	dbo.FormatDateTime(getdate(),'MM/DD/YYYY') as Date_Today,
	case when c.Date_Paid is not null then 'Yes' else 'No' end as LTC

from Datawarehouse.dbo.Student stu with (nolock)
inner join Datawarehouse.dbo.School sch with (nolock)
	on stu.SasiSchoolNum = sch.SasiSchoolNum

left join Student_Device_Coverage c with (nolock)
	on c.Student_ID = stu.StudentId
	and c.School_Year = @School_Year

left join datawarehouse.dbo.School_Calendar cal with (nolock)
	on cal.SchoolYr = @School_Year
	and cal.Term = 'YE'
	
where 1=1
	
	and (
		case when stu.StudentStatus is null then '1' else '0' end in (select * from @Tbl_Student_Status)
		or @Active = 'all'
	)
	and stu.SasiSchoolNum in (
		select * from @Tbl_School_List
	)
	and stu.Grade in (
		select * from @Tbl_Grade_List
	)
	and (case when c.Date_Paid is not null then 'Yes' else 'No'end = @Paid_LTC
		or @Paid_LTC = 'all'
	)

order by
	sch.ShortName,
	Student_Name


GO
