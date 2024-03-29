USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Attachments]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[v_Asset_Tab_Attachments]
AS


select 
	att.ID,
	att.Asset_ID,
	a.Tag_ID,
	a.Serial_Number,
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
	case when atamp.ID is not null then 'Yes' else 'No' end as Is_Tampered_Attachment,
	att_type.ID as Attachment_Type_ID,
	att_type.Name as Attachment_Type_Desc,
	att.Asset_Student_Transaction_ID,
	case 
		when astu.Student_ID is not null then astu.Student_ID 
		when atamp.Student_ID is not null then atamp.Student_ID
		else null 
	end as Student_ID,
	case 
		when astu.Student_ID is not null then Datawarehouse.dbo.getStudentNameById(astu.Student_ID)
		when atamp.Student_ID is not null then Datawarehouse.dbo.getStudentNameById(atamp.Student_ID)
		else null 
	end as Student_Name,
	case 
		when astu.Student_ID is not null then Datawarehouse.dbo.getStudentNameById(astu.Student_ID) + ' (' + astu.Student_ID +')'
		when atamp.Student_ID is not null then Datawarehouse.dbo.getStudentNameById(atamp.Student_ID) + ' (' + atamp.Student_ID +')'
		else null 
	end as Student_Name_ID,
	att.Description as Attachment_Description,
	case 
		when @@SERVERNAME = 'reno-sqlis' then '\\MCS-APPS\C$\Project\CAIRS\Asset_Attachment'
		else '\\MCS-APPS-TEST\C$\Project\CAIRS\Asset_Attachment\' 
	end + cast(att.Asset_ID as varchar(100)) + '\' + att.Name  + '.' + ft.Name as Folder_Location
	

from Asset_Attachment att with (nolock)
inner join CT_File_Type ft with (nolock)
	on ft.ID = att.File_Type_ID
inner join Asset a with (nolock)
	on a.ID = att.Asset_ID
inner join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
inner join CT_Site s with (nolock)
	on s.ID = am.Site_ID

left join CT_Attachment_Type att_type
	on att_type.ID = att.Attachment_Type_ID
left join Asset_Tamper atamp with(nolock)
	on atamp.ID = att.Asset_Tamper_ID
left join Asset_Student_Transaction astu
	on astu.ID = att.Asset_Student_Transaction_ID





















GO
