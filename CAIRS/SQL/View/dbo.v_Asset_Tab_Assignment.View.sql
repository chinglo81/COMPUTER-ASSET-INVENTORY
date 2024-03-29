USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Assignment]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















CREATE VIEW [dbo].[v_Asset_Tab_Assignment]
AS

select
	astu.ID, 
	a.Asset_ID,
	astu.Student_ID,
	stu.LastName + ', ' + stu.FirstName as Assigned_To_Student,
	astu.Student_School_Number,
	stuSchool.Short_Name as Student_Check_Out_School,
	--astu.School_Year,
	case when cal.SchoolYear is not null then cal.SchoolYear else cast(astu.School_Year as varchar) end as School_Year,
	astu.Check_Out_Asset_Condition_ID,
	chkOutCond.Name as Check_Out_Asset_Condition_Desc,
	astu.Check_Out_By_Emp_ID,
	dbo.ProperCase(Datawarehouse.dbo.getEmployeeNameById(astu.Check_Out_By_Emp_ID)) as Check_Out_By_Emp_Name,
	dbo.FormatDateTime(astu.Date_Check_Out,'MM/DD/YYYY') as Date_Check_Out_Formatted,
	astu.Date_Check_Out,
	astu.Check_In_Asset_Condition_ID,
	chkInCond.Name as Check_In_Asset_Condition_Desc,
	astu.Check_In_By_Emp_ID,
	dbo.ProperCase(Datawarehouse.dbo.getEmployeeNameById(astu.Check_In_By_Emp_ID)) as Check_In_By_Emp_Name,
	dbo.FormatDateTime(astu.Date_Check_In,'MM/DD/YYYY') as Date_Check_In_Formatted,
	astu.Date_Check_In,
	case when coverage.School_Year is not null then 'Yes (Paid: ' + dbo.FormatDateTime(coverage.Date_Paid,'MM/DD/YYYY') + ')' else 'No' end as Has_Insurance,
	stu.LastName + ', ' + stu.FirstName + ' (' + a.Student_ID + ') - ' + case when astu.Date_Check_In is null then 'Currently Assigned' else 'Checked-in: ' + dbo.FormatDateTime(astu.Date_Check_In, 'mm/dd/yyyy') end as Display_Name
	
from v_Asset_Master_List a with (nolock)
inner join Asset_Student_Transaction astu with (nolock)
	on astu.Asset_ID = a.Asset_ID
inner join Datawarehouse.dbo.Student stu with (nolock)
	on stu.StudentId = astu.Student_ID

--left join Datawarehouse.dbo.School stuSchool with (nolock)
	--on astu.Student_School_Number = stuSchool.SchoolNum
left join CT_Site stuSchool with (nolock)
	on stuSchool.Code = astu.Student_School_Number 
left join CT_Asset_Condition chkOutCond with (nolock)
	on chkOutCond.ID = astu.Check_Out_Asset_Condition_ID
left join CT_Asset_Condition chkInCond with (nolock)
	on chkInCond.ID = astu.Check_In_Asset_Condition_ID
left join Datawarehouse.dbo.School_Calendar cal with(nolock)
	on cal.SchoolYr = astu.School_Year
	and cal.Term = 'YE'
left join Student_Device_Coverage coverage with (nolock)
	on coverage.Student_ID = astu.Student_ID
	and astu.School_Year = coverage.School_Year
	and coverage.Date_Paid between cast(astu.Date_Check_Out as date) and isnull(astu.Date_Check_In, cast(getdate() as date))
	and a.Asset_Base_Type_ID = 1 --coverage only for laptops











GO
