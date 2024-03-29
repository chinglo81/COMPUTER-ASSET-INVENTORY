USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Student_Assignment]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





























CREATE VIEW [dbo].[v_Asset_Student_Assignment]
AS

with transaction_fee as (
	select 
		f.Asset_Student_Transaction_ID,
		max(f.ID) as Asset_Student_Fee_ID,
		cast(sum(f.Owed_Amount) as decimal(10,2)) as Fee_Amount
	from Asset_Student_Fee f
	where 1=1
		and f.Is_Active = 1
	group by
		f.Asset_Student_Transaction_ID
	
)

select 
	ast.ID,
	ast.School_Year,
	ast.Student_ID,
	stu.Grade as Student_Current_Grade,
	Datawarehouse.dbo.getStudentNameById(ast.Student_ID) as Student_Name,
	Datawarehouse.dbo.getStudentNameById(ast.Student_ID) + ' (' + ast.Student_ID + ')' as Student_Name_And_ID,
	ast.Student_School_Number,
	stuSchool.ShortName as Student_School_Name,
	ast.Asset_ID,
	a.Tag_ID,
	a.Serial_Number,
	a.Asset_Disposition_ID,
	disp.Name as Asset_Disposition_Desc, 
	at.Asset_Base_Type_ID,
	btype.Name as Asset_Base_Type_Desc,
	a.Asset_Type_ID,
	at.Name as Asset_Type_Desc,
	sm.Site_ID as Asset_Site_ID,
	s.Short_Name as Asset_Site_Desc,
	s.Code as Asset_Site_Code,
	--Check Out
	ast.Check_Out_Asset_Condition_ID,
	chkOutCond.Name as Check_Out_Asset_Condition_Desc,
	ast.Date_Check_Out,
	dbo.FormatDateTime(ast.Date_Check_Out,'MM/DD/YYYY') as Date_Check_Out_Formatted,
	dbo.FormatDateTime(ast.Date_Check_Out,'HH:MM AM/PM') as Time_Check_Out_Formatted,
	ast.Check_Out_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(ast.Check_Out_By_Emp_ID)) as Check_Out_By_Emp_Name,
	--Check In
	ast.Check_In_Type_ID,
	chkin_type.Name as Check_In_Type_Desc,
	ast.Check_In_Asset_Condition_ID,
	chkInCond.Name as Check_In_Asset_Condition_Desc,
	ast.Date_Check_In,
	dbo.FormatDateTime(ast.Date_Check_In,'MM/DD/YYYY') as Date_Check_In_Formatted,
	dbo.FormatDateTime(ast.Date_Check_In,'HH:MM AM/PM') as Time_Check_in_Formatted,
	ast.Check_In_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(ast.Check_In_By_Emp_ID)) as Check_In_By_Emp_Name,
	chk_in_disp.ID as Check_In_Disposition_ID,
	chk_in_disp.Name as Check_In_Disposition_Desc,
	isnull(ast.Stu_Responsible_For_Damage, 0) as Stu_Responsible_For_Damage,
	ast.Is_Police_Report_Provided,
	--END
	bm.Bin_ID,
	b.Number as Bin_Number,
	cast(b.Number as varchar(100)) + case when len(b.Description) > 0 then ' - ' + left(b.Description, 20) + case when len(b.Description) > 20 then '...' else '' end else '' end as Bin_Number_And_Desc,
	--Fee
	isnull(fee.Fee_Amount, 0) as Fine_Amount,
	case when coverage.Date_Paid is not null then 'Yes' else 'No' end as Has_Limited_Technology_Coverage,
	ast.Comment as Asset_Student_Fee_Comment

from Asset_Student_Transaction ast with (nolock)
inner join Datawarehouse.dbo.Student stu with (nolock)
	on stu.StudentId = ast.Student_ID
inner join Asset a with (nolock)
	on a.ID = ast.Asset_ID
inner join CT_Asset_Disposition disp with (nolock)
	on disp.ID = a.Asset_Disposition_ID
inner join Datawarehouse.dbo.School stuSchool with(nolock)
	on stuSchool.SasiSchoolNum = stu.SasiSchoolNum

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
left join transaction_fee fee with (nolock)
	on fee.Asset_Student_Transaction_ID = ast.ID
left join Asset_Student_Fee most_recent_fee with (nolock)
	on most_recent_fee.ID = fee.Asset_Student_Fee_ID
	and most_recent_fee.Is_Active = 1
left join Student_Device_Coverage coverage with (nolock)
	on coverage.Student_ID = ast.Student_ID
	and coverage.School_Year = ast.School_Year
left join CT_Asset_Disposition chk_in_disp
	on chk_in_disp.ID = ast.Check_In_Disposition_ID
left join CT_Check_In_Type chkin_type
	on chkin_type.ID = ast.Check_In_Type_ID

































GO
