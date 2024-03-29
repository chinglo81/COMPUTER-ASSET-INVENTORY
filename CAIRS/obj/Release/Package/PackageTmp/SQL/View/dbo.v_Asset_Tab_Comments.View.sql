USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Comments]    Script Date: 2/3/2017 10:34:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[v_Asset_Tab_Comments]
AS


select 
	c.ID,
	c.Asset_ID,
	c.Comment,
	left(c.Comment, 30) + case when len(c.comment) > 30 then '...Details for Entire Comment' else '' end as Comment_Short,
	c.Added_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(c.Added_By_Emp_ID)) as Added_By_Emp_Name,
	c.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(c.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	dbo.FormatDateTime(c.Date_Added, 'MM/DD/YYYY HH:MM AM/PM') as Date_Added,
	dbo.FormatDateTime(c.Date_Modified, 'MM/DD/YYYY HH:MM AM/PM') as Date_Modified,
	dbo.FormatDateTime(ISNULL(c.Date_Modified, c.Date_Added), 'MM/DD/YYYY HH:MM AM/PM') as Recent_Date
from Asset_Comment c






GO
