USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Master_List]    Script Date: 2/3/2017 10:34:41 AM ******/
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
	from Audit_Log
	where Table_Name = 'Asset'
	group by
		Primary_Key_ID
),

LastAssignStudent as (
	select
		Asset_ID,
		max(id) as Asset_Student_Transaction_ID
	from Asset_Student_Transaction
	group by
		Asset_ID
)

select 
	a.ID as Asset_ID,
	a.Tag_ID, 
	a.Serial_Number,
	s.Site_ID as Asset_Site_ID,
	site.Name as Asset_Site_Desc,
	bm.Bin_ID,
	b.Number as Bin_Number,
	b.Description as Bin_Desc,
	a.Asset_Assignment_Type_ID,
	assignType.Name as Asset_Assignment_Type_Desc,
	a.Asset_Disposition_ID,
	disp.Name as Asset_Disposition_Desc,
	a.Asset_Condition_ID,
	cond.Name as Asset_Condition_Desc,
	a.Asset_Type_ID,
	assetType.Name as Asset_Type_Desc,
	a.Date_Purchased,
	a.Added_By_Emp_ID,
	AddedByEmp.LastName + ', ' + AddedByEmp.FirstName as Added_By_Emp_Desc,
	audit.Emp_ID as Modified_By_Emp_ID,
	LastModifiedByEmp.LastName + ', ' + LastModifiedByEmp.FirstName as Modified_By_Emp_Desc,
	astu.Student_ID,
	stu.LastName + ', ' + stu.FirstName as Student_Assigned_To,
	CASE WHEN a.Is_Leased = 1 then 'Yes' else 'No' end as Is_Leased,
	CASE WHEN a.Is_Active = 1 then 'Yes' else 'No' end as Is_Active_Desc,
	a.Is_Active,
	disp.Allow_Inactivate,
	a.Date_Added

from Asset a

left join Asset_Site_Mapping s
	on s.Asset_ID = a.ID
left join CT_Site site
	on site.ID = s.Site_ID

left join Asset_Bin_Mapping bm
	on bm.Asset_ID = a.ID
left join Bin b
	on b.ID = bm.Bin_ID

left join CT_Asset_Assignment_Type assignType
	on assignType.ID = a.Asset_Assignment_Type_ID
left join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
left join CT_Asset_Condition cond
	on cond.ID = a.Asset_Condition_ID
left join CT_Asset_Type assetType
	on assetType.ID = a.Asset_Type_ID
left join Datawarehouse.dbo.Employees AddedByEmp
	on AddedByEmp.empdistid = a.Added_By_Emp_ID
left join LastModifiedAssetEmp LastModified
	on LastModified.Asset_ID = a.ID
left join Audit_Log audit
	on audit.ID = LastModified.Audit_Log_ID
left join Datawarehouse.dbo.Employees LastModifiedByEmp
	on LastModifiedByEmp.empdistid = audit.Emp_ID

left join LastAssignStudent lastu
	on lastu.Asset_ID = a.ID
left join Asset_Student_Transaction astu
	on astu.ID = lastu.Asset_Student_Transaction_ID
left join datawarehouse.dbo.student stu
	on stu.StudentId = astu.Student_ID 






GO
