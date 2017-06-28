USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Student_Asset_Search]    Script Date: 6/28/2017 11:00:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




















CREATE VIEW [dbo].[v_Student_Asset_Search]
AS


Select
	ast.ID as Asset_Student_Transaction_ID,
	ast.School_Year,
	ast.Student_ID,
	stu.SasiSchoolNum as Student_Current_School,
	stuCurrentSchool.Short_Name as Student_Current_School_Desc,
	Datawarehouse.dbo.getStudentNameById(ast.Student_ID) as Student_Name,
	ast.Student_School_Number,
	stusSchool.Short_Name as Student_School_Name,
	a.Tag_ID,
	at.Asset_Base_Type_ID,
	btype.Name as Asset_Base_Type_Desc,
	a.Asset_Type_ID,
	at.Name as Asset_Type_Desc, 
	--Check Out
	ast.Check_Out_Asset_Condition_ID,
	chkOutCond.Name as Check_Out_Asset_Condition_Desc,
	ast.Date_Check_Out,
	dbo.FormatDateTime(ast.Date_Check_Out,'MM/DD/YYYY') as Date_Check_Out_Formatted,
	ast.Check_Out_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(ast.Check_Out_By_Emp_ID)) as Check_Out_By_Emp_Name,
	--Check In
	isnull(ast.Check_In_Disposition_ID, disp.ID) as Check_In_Disposition_ID,
	isnull(chkInDisp.Name, disp.Name) as Check_In_Asset_Disposition_Desc,
	ast.Check_In_Asset_Condition_ID,
	chkInCond.Name as Check_In_Asset_Condition_Desc,
	ast.Date_Check_In,
	dbo.FormatDateTime(ast.Date_Check_In,'MM/DD/YYYY') as Date_Check_In_Formatted,
	ast.Check_In_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(ast.Check_In_By_Emp_ID)) as Check_In_By_Emp_Name,
	'$' + cast(isnull(fee_owed.Owed_Amount, 0) as varchar(100)) as Owed_Amount,
	case when isnull(fee_owed.Owed_Amount, 0) > 0 then 'Yes' else 'No' end as Owes_Fee,
	found_disp.Name as Found_Asset_Disposition_Desc,
	found_cond.Name as Found_Asset_Condition_Desc,
	dbo.FormatDateTime(ast.Found_Date,'MM/DD/YYYY') as Date_Found_Formatted
	
from Asset_Student_Transaction ast with (nolock)
inner join Datawarehouse.dbo.Student stu with (nolock)
	on stu.StudentId = ast.Student_ID
inner join Asset a with (nolock)
	on a.ID = ast.Asset_ID
--inner join Datawarehouse.dbo.School stusSchool with (nolock)
	--on stusSchool.SchoolNum = ast.Student_School_Number
inner join CT_Site stusSchool with (nolock)
	on stusSchool.Code = ast.Student_School_Number
inner join CT_Asset_Disposition disp with (nolock)
	on disp.ID = a.Asset_Disposition_ID

--left join Datawarehouse.dbo.School stuCurrentSchool with (nolock)
	--on stuCurrentSchool.SasiSchoolNum = stu.SasiSchoolNum
left join CT_Site stuCurrentSchool with (nolock)
	on stuCurrentSchool.Code = stu.SasiSchoolNum
left join CT_Asset_Type at with (nolock)
	on at.ID = a.Asset_Type_ID
left join CT_Asset_Base_Type btype with (nolock)
	on btype.ID = at.Asset_Base_Type_ID
left join CT_Asset_Condition chkOutCond with (nolock)
	on chkOutCond.ID = ast.Check_Out_Asset_Condition_ID
left join CT_Asset_Condition chkInCond with (nolock)
	on chkInCond.ID = ast.Check_In_Asset_Condition_ID
left join CT_Asset_Disposition chkInDisp with (nolock)
	on chkInDisp.ID = ast.Check_In_Disposition_ID
left join (
	select 
		fee.Asset_Student_Transaction_ID,
		sum(fee.Owed_Amount) as Owed_Amount
	from Asset_Student_Fee fee
	group by
		fee.Asset_Student_Transaction_ID
)
fee_owed
	on fee_owed.Asset_Student_Transaction_ID = ast.ID
left join CT_Asset_Disposition found_disp
	on found_disp.ID = Found_Disposition_ID
left join CT_Asset_Condition found_cond
	on found_cond.ID = ast.Found_Asset_Condition_ID






















GO
