USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Repairs]    Script Date: 2/3/2017 10:34:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[v_Asset_Tab_Repairs]
AS

select 
	r.ID,
	r.Asset_ID,
	astu.ID as Asset_Student_Transaction_ID,
	astu.Student_ID,
	stu.LastName + ', ' + stu.FirstName as Student_Name,
	r.Repair_Type_ID,
	rt.Name as Repair_Type_Desc,
	r.Comment,
	cast(dbo.FormatDateTime(r.Date_Sent, 'MM/DD/YYYY') as Date) as Date_Sent,
	cast(dbo.FormatDateTime(r.Date_Received, 'MM/DD/YYYY') as Date) as Date_Received,
	r.Received_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(r.Received_By_Emp_ID)) as Received_By_Emp_Name,
	r.Added_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(r.Added_By_Emp_ID)) as Added_By_Emp_Name,
	r.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(r.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	dbo.FormatDateTime(r.Date_Added, 'MM/DD/YYYY HH:MM AM/PM') as Date_Added,
	dbo.FormatDateTime(r.Date_Modified, 'MM/DD/YYYY HH:MM AM/PM') as Date_Modified

from Asset_Repair r
left join Asset_Student_Transaction astu
	on astu.ID = r.Asset_Student_Transaction_ID
left join CT_Repair_Type rt
	on rt.ID = r.Repair_Type_ID
left join Datawarehouse.dbo.Student stu
	on stu.StudentId = astu.Student_ID







GO
