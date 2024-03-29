USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Info_CheckIn]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE VIEW [dbo].[v_Asset_Info_CheckIn]
AS

with LastAssignStudent as (
	select
		Asset_ID,
		max(id) as Asset_Student_Transaction_ID
	from Asset_Student_Transaction with (nolock)
	group by
		Asset_ID
)

select 
	astu.ID as Asset_Student_Transaction_ID,
	a.ID as Asset_ID,
	am.Site_ID as Asset_Site_ID,
	s.Short_Name as Asset_Site_Desc,
	a.Tag_ID,
	a.Serial_Number,
	a.Asset_Disposition_ID,
	disp.Name as Asset_Disposition_Desc,
	disp.Code as Asset_Disposition_Code,
	case when allow_check_in.Code IS NULL then 0 else 1 end as Disposition_Allow_CheckIn,
	case when allow_check_in.Code IS NULL then 'No' else 'Yes' end as Disposition_Allow_CheckIn_Desc,
	atype.Asset_Base_Type_ID,
	btype.Name as Asset_Base_Type_Desc,
	a.Asset_Type_ID,
	atype.Name as Asset_Type_Desc,
	astu.Student_ID,
	datawarehouse.dbo.getStudentNameById(astu.Student_ID) as Student_Name,
	astu.School_Year,
	astu.Date_Check_Out,
	dbo.FormatDateTime(astu.Date_Check_Out, 'MM/DD/YYYY') as Date_Check_Out_Formatted,
	astu.Check_Out_Asset_Condition_ID,
	chkOutCond.Name as Check_Out_Asset_Condition_Desc,
	astu.Date_Check_In
	
from Asset a with (nolock)
inner join CT_Asset_Disposition disp with (nolock)
	on disp.ID = a.Asset_Disposition_ID
inner join CT_Asset_Type atype with (nolock)
	on atype.ID = a.Asset_Type_ID
inner join CT_Asset_Base_Type btype with (nolock)
	on btype.ID = atype.Asset_Base_Type_ID

left join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
left join CT_Site s with (nolock)
	on s.ID = am.Site_ID
left join LastAssignStudent lstu with (nolock)
	on lstu.Asset_ID = a.ID
left join Asset_Student_Transaction astu with (nolock)
	on astu.ID = lstu.Asset_Student_Transaction_ID
left join CT_Asset_Condition chkOutCond with (nolock)
	on chkOutCond.ID = astu.Check_Out_Asset_Condition_ID
left join (
	select distinct
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_CheckIn'
		and b.Table_Name = 'CT_Asset_Disposition'
) allow_check_in
	on allow_check_in.Code = disp.Code













GO
