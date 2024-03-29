USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Comments]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[v_Asset_Tab_Comments]
AS


select 
	c.ID,
	c.Asset_ID,
	s.ID as Asset_Site_ID,
	s.Short_Name as Asset_Site_Desc,
	s.Code as Asset_Site_Code,
	c.Comment,
	left(c.Comment, 30) + case when len(c.comment) > 30 then '...' else '' end as Comment_Short,
	c.Added_By_Emp_ID,
	isnull(dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(c.Added_By_Emp_ID)), c.Added_By_Emp_ID) as Added_By_Emp_Name,
	c.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(c.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	dbo.FormatDateTime(c.Date_Added, 'MM/DD/YYYY') as Date_Added_Formatted,
	dbo.FormatDateTime(c.Date_Modified, 'MM/DD/YYYY') as Date_Modified_Formatted,
	dbo.FormatDateTime(ISNULL(c.Date_Modified, c.Date_Added), 'MM/DD/YYYY') as Recent_Date_Formatted,
	c.Date_Added,
	c.Date_Modified,
	ISNULL(c.Date_Modified, c.Date_Added) as Recent_Date
from Asset_Comment c with (nolock)
inner join Asset a with (nolock)
	on a.ID = c.Asset_ID
inner join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
inner join CT_Site s with (nolock)
	on s.ID = am.Site_ID











GO
