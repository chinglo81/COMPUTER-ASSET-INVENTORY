USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Tamper]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[v_Asset_Tab_Tamper]
AS


select 
	distinct
	--Asset Info
	amas.Tag_ID,
	amas.Serial_Number,
	amas.Asset_Site_Desc,
	amas.Asset_Site_Code,
	amas.Asset_Base_Type_Desc,
	amas.Asset_Type_Desc,
	--Tamper Info
	stusch.ShortName as Student_School_Desc, 
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
inner join v_Asset_Master_List amas with (nolock)
	on amas.Asset_ID = t.Asset_ID

left join Asset_Attachment att with (nolock)
	on att.Asset_Tamper_ID = t.id
left join Datawarehouse.dbo.School stusch
	on stusch.SasiSchoolNum = t.Student_School_Number










GO
