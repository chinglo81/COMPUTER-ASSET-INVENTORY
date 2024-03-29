USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Attachments]    Script Date: 2/3/2017 10:34:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[v_Asset_Tab_Attachments]
AS


select 
	att.ID,
	att.Asset_ID,
	att.Added_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(att.Added_By_Emp_ID)) as Added_By_Emp_Name,
	--dbo.FormatDateTime(att.Date_Added, 'MM/DD/YYYY') as Date_Added,
	att.Date_Added,
	att.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(att.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	--dbo.FormatDateTime(att.Date_Modified, 'MM/DD/YYYY') as Date_Modified,
	att.Date_Modified,
	att.Description,
	att.File_Type_ID,
	ft.Name as File_Type_Desc,
	att.Name
from Asset_Attachment att
inner join CT_File_Type ft
	on ft.ID = att.File_Type_ID











GO
