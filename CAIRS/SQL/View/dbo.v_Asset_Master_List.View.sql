USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Master_List]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















CREATE VIEW [dbo].[v_Asset_Master_List]
AS

with LastModifiedAssetEmp as (
	select
		Primary_Key_ID as Asset_ID,
		max(id) as Audit_Log_ID
	from Audit_Log with (nolock)
	where Table_Name = 'Asset'
	group by
		Primary_Key_ID
),

LastAssignStudent as (
	select
		Asset_ID,
		max(id) as Asset_Student_Transaction_ID
	from Asset_Student_Transaction with (nolock)
	group by
		Asset_ID
),

ADP_Leased_Info as (
	select 
		r.Asset_ID,
		count(*) as ADP_Count
	from Asset_Repair r with (nolock)
	where 1=1
		and r.Is_Leased = 1
		and r.Repair_Type_ID = 1 --Accidental
	group by
		r.Asset_ID
),

Law_Enforcement as (
	select
		a.Asset_ID,
		count(*) as Law_Enforcement_Count
	from Asset_Law_Enforcement a with (nolock)
	group by
		a.Asset_ID
)

select 
	a.ID as Asset_ID,
	a.Tag_ID, 
	a.Serial_Number,
	s.Site_ID as Asset_Site_ID,
	site.Short_Name as Asset_Site_Desc,
	site.Code as Asset_Site_Code,
	bm.Bin_ID,
	b.Number as Bin_Number,
	b.Description as Bin_Desc,
	bin_site.ID as Bin_Site_ID,
	bin_site.Short_Name + ' - Bin #' + cast(b.Number as varchar) as Bin_Site_Desc,
	a.Asset_Assignment_Type_ID,
	assignType.Name as Asset_Assignment_Type_Desc,
	a.Asset_Disposition_ID,
	disp.Name as Asset_Disposition_Desc,
	a.Asset_Condition_ID,
	cond.Name as Asset_Condition_Desc,
	a.Asset_Type_ID,
	assetType.Name as Asset_Type_Desc,
	assetType.Asset_Base_Type_ID,
	baseType.Name as Asset_Base_Type_Desc,
	dbo.FormatDateTime(a.Date_Purchased,'MM/DD/YYYY') as Date_Purchased,
	a.Added_By_Emp_ID,
	AddedByEmp.LastName + ', ' + AddedByEmp.FirstName as Added_By_Emp_Desc,
	audit.Emp_ID as Modified_By_Emp_ID,
	isnull(LastModifiedByEmp.LastName + ', ' + LastModifiedByEmp.FirstName, audit.Emp_ID) as Modified_By_Emp_Desc,
	astu.Student_ID,
	Datawarehouse.dbo.getStudentNameById(astu.Student_ID) + ' (' + astu.Student_ID + ')' as Student_Name,
	stu.LastName + ', ' + stu.FirstName as Student_Assigned_To,
	stu.LastName + ', ' + stu.FirstName + ' - ' + astu.Student_ID as Student_Assigned_To_And_ID,
	CASE WHEN a.Is_Leased = 1 then 'Yes' else 'No' end as Is_Leased,
	CASE WHEN a.Is_Active = 1 then 'Yes' else 'No' end as Is_Active_Desc,
	a.Is_Active,
	--disp.Allow_Inactivate,
	case when allowInactivate.Code is null then 0 else 1 end as Allow_Inactivate,
	case when allowInactivate.Code is null then 'No' else 'Yes' end as Allow_Inactivate_Desc,
	a.Date_Added,
	lastu.Asset_Student_Transaction_ID,
	astu.Date_Check_In,
	astu.Date_Check_Out,
	a.Leased_Term_Days,
	a.Warranty_Term_Days,
	isnull(DATEADD(DAY, a.Leased_Term_Days, a.Date_Purchased), GETDATE()) as Leased_Term_Date,
	isnull(DATEADD(DAY, a.Warranty_Term_Days, a.Date_Purchased), GETDATE()) as Warranty_Term_Date,
	case 
		when DATEADD(DAY, a.Leased_Term_Days, a.Date_Purchased) is not null 
			then cast(a.Leased_Term_Days as varchar(10)) + ' (' + dbo.FormatDateTime(DATEADD(DAY, a.Leased_Term_Days, a.Date_Purchased), 'MM/DD/YYYY') + ')' 
			else '' 
	end as Leased_Term_Date_Desc,
	case 
		when DATEADD(DAY, a.Warranty_Term_Days, a.Date_Purchased) is not null 
			then cast(a.Warranty_Term_Days as varchar(10)) + ' (' + dbo.FormatDateTime(DATEADD(DAY, a.Warranty_Term_Days, a.Date_Purchased), 'MM/DD/YYYY') + ')' 
			else '' 
	end as Warranty_Term_Date_Desc,
	isnull(leased_adp.ADP_Count, 0) as Leased_ADP_Count,
	case when allowDeadpool.Code is null then 0 else 1 end as Allow_Deadpool,
	case when allowEwaste.Code is null then 0 else 1 end as Allow_Ewaste,
	case when allowCreateRepair.Code is null then 0 else 1 end as Allow_Create_Repair,
	case when allowTransfer.Code is null then 0 else 1 end as Allow_Transfer,
	case when NotAllowLawEnforcement.Code is null then 1 else 0 end as Allow_Law_Enforcement,
	case when disable_add_function.Code is null then 0 else 1 end as Disable_Add_By_Base_Type,
	isnull(le.Law_Enforcement_Count, 0) as Law_Enforcement_Count

from Asset a with (nolock)

left join Asset_Site_Mapping s with (nolock)
	on s.Asset_ID = a.ID
left join CT_Site site with (nolock)
	on site.ID = s.Site_ID
left join Asset_Bin_Mapping bm with (nolock)
	on bm.Asset_ID = a.ID
left join Bin b with (nolock)
	on b.ID = bm.Bin_ID
left join CT_Site bin_site
	on bin_site.ID = b.Site_ID
left join CT_Asset_Assignment_Type assignType with (nolock)
	on assignType.ID = a.Asset_Assignment_Type_ID
left join CT_Asset_Disposition disp with (nolock)
	on disp.ID = a.Asset_Disposition_ID
left join CT_Asset_Condition cond with (nolock)
	on cond.ID = a.Asset_Condition_ID
left join CT_Asset_Type assetType with (nolock)
	on assetType.ID = a.Asset_Type_ID
left join CT_Asset_Base_Type baseType with (nolock)
	on assetType.Asset_Base_Type_ID = baseType.ID
left join Datawarehouse.dbo.Employees AddedByEmp with (nolock)
	on AddedByEmp.empdistid = a.Added_By_Emp_ID
left join LastModifiedAssetEmp LastModified with (nolock)
	on LastModified.Asset_ID = a.ID
left join Audit_Log audit with (nolock)
	on audit.ID = LastModified.Audit_Log_ID
left join Datawarehouse.dbo.Employees LastModifiedByEmp with (nolock)
	on LastModifiedByEmp.empdistid = audit.Emp_ID
left join LastAssignStudent lastu with (nolock)
	on lastu.Asset_ID = a.ID
left join Asset_Student_Transaction astu with (nolock)
	on astu.ID = lastu.Asset_Student_Transaction_ID
left join datawarehouse.dbo.student stu with (nolock)
	on stu.StudentId = astu.Student_ID 
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_Inactivate'
		and b.Table_Name = 'CT_Asset_Disposition'
) allowInactivate 
	on allowInactivate.Code = disp.Code
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_Ewaste'
		and b.Table_Name = 'CT_Asset_Disposition'
) allowEwaste 
	on allowEwaste.Code = disp.Code
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_Deadpool'
		and b.Table_Name = 'CT_Asset_Disposition'
) allowDeadpool 
	on allowDeadpool.Code = disp.Code
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_Create_Repair'
		and b.Table_Name = 'CT_Asset_Disposition'
) allowCreateRepair 
	on allowCreateRepair.Code = disp.Code
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_Transfer'
		and b.Table_Name = 'CT_Asset_Disposition'
) allowTransfer 
	on allowTransfer.Code = disp.Code
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Not_Allow_Create_Law_Enforcement'
		and b.Table_Name = 'CT_Asset_Disposition'
) NotAllowLawEnforcement 
	on NotAllowLawEnforcement.Code = disp.Code
left join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disable_Action_For_Base_Type'
		and b.Table_Name = 'CT_Asset_Base_Type'
) disable_add_function 
	on disable_add_function.Code = baseType.Code

left join ADP_Leased_Info leased_adp
	on leased_adp.Asset_ID = a.ID
left join Law_Enforcement le
	on le.Asset_ID = a.ID






































GO
