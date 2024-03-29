USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Student_CheckIn_No_Tag_ID]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[v_Student_CheckIn_No_Tag_ID]
AS


select 
	ast.ID,
	ast.Asset_ID,
	ast.School_Year,
	ast.Student_ID,
	Datawarehouse.dbo.getStudentNameById(ast.Student_ID) as Student_Name,
	ast.Student_School_Number,
	stusSchool.Short_Name as Student_School_Name,
	a.Tag_ID,
	a.Serial_Number,
	a.Asset_Disposition_ID,
	disp.Name as Asset_Disposition_Desc, 
	at.Asset_Base_Type_ID,
	btype.Name as Asset_Base_Type_Desc,
	a.Asset_Type_ID,
	at.Name as Asset_Type_Desc,
	sm.Site_ID as Asset_Site_ID,
	s.Name as Asset_Site_Desc,
	--Check Out
	ast.Check_Out_Asset_Condition_ID,
	chkOutCond.Name as Check_Out_Asset_Condition_Desc,
	dbo.FormatDateTime(ast.Date_Check_Out,'MM/DD/YYYY') as Date_Check_Out,
	ast.Check_Out_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(ast.Check_Out_By_Emp_ID)) as Check_Out_By_Emp_Name,
	--Check In
	ast.Check_In_Asset_Condition_ID,
	chkInCond.Name as Check_In_Asset_Condiction_Desc,
	dbo.FormatDateTime(ast.Date_Check_In,'MM/DD/YYYY') as Date_Check_In,
	ast.Check_In_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(ast.Check_In_By_Emp_ID)) as Check_In_By_Emp_Name,
	--END
	bm.Bin_ID,
	b.Number as Bin_Number,
	DefaultDisp.ID as Default_Disposition_ID,
	DefaultDisp.Name as Default_Disposition_Desc,
	DefaultIType.ID as Default_Interaction_Type_ID,
	DefaultIType.Name as Default_Interaction_Type_Desc


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

left join Asset_Site_Mapping sm with (nolock)
	on sm.Asset_ID = a.ID
left join CT_Site s with (nolock)
	on s.ID = sm.Site_ID
left join CT_Asset_Type at with (nolock)
	on at.ID = a.Asset_Type_ID
left join CT_Asset_Base_Type btype with (nolock)
	on btype.ID = at.Asset_Base_Type_ID
left join CT_Asset_Condition chkOutCond with (nolock)
	on chkOutCond.ID = ast.Check_Out_Asset_Condition_ID
left join CT_Asset_Condition chkInCond with (nolock)
	on chkInCond.ID = ast.Check_In_Asset_Condition_ID
left join Asset_Bin_Mapping bm with (nolock)
	on bm.Asset_ID = ast.Asset_ID
left join Bin b with (nolock)
	on b.ID = bm.Bin_ID

cross join CT_Asset_Disposition DefaultDisp with (nolock)
cross join CT_Interaction_Type DefaultIType with (nolock)

where 1=1
	and DefaultDisp.Code = '17'
	and DefaultIType.Code = '1'














GO
