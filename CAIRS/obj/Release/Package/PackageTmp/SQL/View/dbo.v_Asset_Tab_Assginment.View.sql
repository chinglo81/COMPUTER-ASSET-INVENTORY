USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Assginment]    Script Date: 2/3/2017 10:34:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[v_Asset_Tab_Assginment]
AS

select
	astu.ID, 
	a.ID as Asset_ID,
	astu.Student_ID,
	stu.LastName + ', ' + stu.FirstName as Assigned_To_Student,
	astu.Student_School_Number,
	stuSchool.Name as Student_Check_Out_School,
	astu.School_Year,
	astu.Check_Out_Asset_Condition_ID,
	chkOutCond.Name as Check_Out_Asset_Condition_Desc,
	astu.Check_Out_By_Emp_ID,
	dbo.ProperCase(Datawarehouse.dbo.getEmployeeNameById(astu.Check_Out_By_Emp_ID)) as Check_Out_By_Emp_Name,
	dbo.FormatDateTime(astu.Date_Check_Out,'MM/DD/YYYY') as Date_Check_Out,
	astu.Check_In_Asset_Condition_ID,
	chkInCond.Name as Check_In_Asset_Condition_Desc,
	astu.Check_In_By_Emp_ID,
	dbo.ProperCase(Datawarehouse.dbo.getEmployeeNameById(astu.Check_In_By_Emp_ID)) as Check_In_By_Emp_Name,
	dbo.FormatDateTime(astu.Date_Check_In,'MM/DD/YYYY') as Date_Check_In
	
from Asset a
inner join Asset_Student_Transaction astu
	on astu.Asset_ID = a.ID
inner join Datawarehouse.dbo.Student stu
	on stu.StudentId = astu.Student_ID

left join Datawarehouse.dbo.School stuSchool
	on astu.Student_School_Number = stuSchool.SchoolNum
left join CT_Asset_Condition chkOutCond
	on chkOutCond.ID = astu.Check_Out_Asset_Condition_ID
left join CT_Asset_Condition chkInCond
	on chkInCond.ID = astu.Check_In_Asset_Condition_ID






GO
