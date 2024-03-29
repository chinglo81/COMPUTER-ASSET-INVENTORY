USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Add_Asset_Previous_Batch]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[v_Add_Asset_Previous_Batch]
AS

select 
	h.ID as Asset_Temp_Header_ID,
	h.Asset_Site_ID,
	s.Short_Name as Asset_Site_Name_Desc,
	s.Code as Asset_Site_Code,
	dbo.FormatDateTime(ISNULL(max(d.Date_Added), ISNULL(h.Date_Modified, h.Date_Added)), 'MM/DD/YYYY HH:MM AM/PM') as Update_Date,
    h.Description,
    left(h.Description, 50) + case when len(h.Description) > 50 then '...' else '' end as Description_Short,
	count(d.id) Total_Asset,
    case when h.Has_Submit = 1 then 'Yes' else 'No' end as Has_Been_Submitted,
    case when h.Has_Submit = 1 then 'Submitted - ' + dbo.FormatDateTime(h.Date_Submit, 'MM/DD/YYYY') else 'Pending' end as Batch_Status,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(h.Added_By_Emp_ID)) as Added_By_Emp_Name,
	h.Added_By_Emp_ID,
	isnull(h.Has_Submit, 0) as Has_Submit

from Asset_Temp_Header h with (nolock)
inner join CT_Site s with (nolock)
	on s.ID = h.Asset_Site_ID
left join Asset_Temp_Detail d with (nolock)
	on d.Asset_Temp_Header_ID = h.ID

group by
	h.ID,
	h.Asset_Site_ID,
	s.Short_Name,
	s.Code,
	h.Date_Modified,
	h.Date_Added,
	h.Description,
    h.Has_Submit,
    h.Date_Submit,
	h.Added_By_Emp_ID,
	h.Has_Submit










GO
