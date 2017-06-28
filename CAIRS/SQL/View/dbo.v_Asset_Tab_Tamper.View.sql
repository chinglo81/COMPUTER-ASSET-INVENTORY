USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Tamper]    Script Date: 6/28/2017 11:00:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[v_Asset_Tab_Tamper]
AS


select 
	distinct
	s.Short_Name as Asset_Site_Desc,
	s.Code as Asset_Site_Code,
	t.*,
	dbo.FormatDateTime(t.Date_Added, 'MM/DD/YYYY') as Date_Added_Formatted,
	dbo.FormatDateTime(t.Date_Modified, 'MM/DD/YYYY') as Date_Modified_Formatted,
	left(t.Comment, 30) + case when len(t.comment) > 30 then '...' else '' end as Comment_Short,
	Datawarehouse.dbo.getStudentNameById(t.student_id) + ' (' + t.Student_ID + ')' as Student_Name,
	Datawarehouse.dbo.getEmployeeNameById(t.Added_By_Emp_ID) as Added_By_Emp_Name,
	Datawarehouse.dbo.getEmployeeNameById(t.Modified_By_Emp_ID) as Modified_By_Emp_Name,
	case when att.Asset_Tamper_ID is not null then 'Yes' Else 'No' end as Has_Attachment,
	case when t.Date_Processed is not null then dbo.FormatDateTime(t.Date_Processed, 'MM/DD/YYYY') else 'Not Processed' end as Processed
from Asset_Tamper t with (nolock)
inner join Asset a with (nolock)
	on a.ID = t.Asset_ID
inner join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
inner join CT_Site s with (nolock)
	on s.ID = am.Site_ID

left join Asset_Attachment att with (nolock)
	on att.Asset_Tamper_ID = t.id








GO
