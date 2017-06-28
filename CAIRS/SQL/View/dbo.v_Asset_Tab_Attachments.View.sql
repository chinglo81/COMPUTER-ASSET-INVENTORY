USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Attachments]    Script Date: 6/28/2017 11:00:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[v_Asset_Tab_Attachments]
AS


select 
	att.ID,
	att.Asset_ID,
	s.ID as Asset_Site_ID,
	s.Short_Name as Asset_Site_Desc,
	s.Code as Asset_Site_Code,
	att.Added_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(att.Added_By_Emp_ID)) as Added_By_Emp_Name,
	dbo.FormatDateTime(att.Date_Added, 'MM/DD/YYYY') as Date_Added_Formatted,
	att.Date_Added,
	att.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(att.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	dbo.FormatDateTime(att.Date_Modified, 'MM/DD/YYYY') as Date_Modified_Formatted,
	att.Date_Modified,
	att.Description,
	att.File_Type_ID,
	ft.Name as File_Type_Desc,
	att.Name,
	atamp.ID as Asset_Tamper_ID,
	case when atamp.ID is not null then 'Yes' else 'No' end as Is_Tampered_Attachment
from Asset_Attachment att with (nolock)
inner join CT_File_Type ft with (nolock)
	on ft.ID = att.File_Type_ID
inner join Asset a with (nolock)
	on a.ID = att.Asset_ID
inner join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
inner join CT_Site s with (nolock)
	on s.ID = am.Site_ID

left join Asset_Tamper atamp
	on atamp.ID = att.Asset_Tamper_ID

















GO
