USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Law_Enforcement]    Script Date: 6/28/2017 11:00:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[v_Asset_Law_Enforcement]
AS


select 
	le.ID,
	le.Asset_ID,
	le.Law_Enforcement_Agency_ID,
	la.Name as Law_Enforcement_Agency_Name,
	la.Short_Name as Law_Enforcement_Agency_Short_Name,
	s.Code as Asset_Site_Code,
	isnull(s.Short_Name, s.Name) as Asset_Site_Desc,
	le.Officer_First_Name,
	le.Officer_Last_Name,
	le.Officer_Last_Name + ', ' + le.Officer_First_Name as Officer_Full_Name,
	le.Case_Number,
	le.Comment,
	left(le.Comment, 30) + case when len(le.Comment) > 30 then '...' else '' end as Comment_Short,
	le.Date_Picked_Up,
	dbo.FormatDateTime(le.Date_Picked_Up,'MM/DD/YYYY') as Date_Picked_Up_Formatted,
	le.Date_Returned,
	dbo.FormatDateTime(le.Date_Returned,'MM/DD/YYYY') as Date_Returned_Formatted,
	le.Received_By_Emp_ID,
	Datawarehouse.dbo.getEmployeeNameById(le.Received_By_Emp_ID) as Received_By_Emp_Name,
	le.Added_By_Emp_ID,
	Datawarehouse.dbo.getEmployeeNameById(le.Added_By_Emp_ID) as Added_By_Emp_Name,
	le.Modified_By_Emp_ID,
	Datawarehouse.dbo.getEmployeeNameById(le.Modified_By_Emp_ID) as Modified_By_Emp_Name

from Asset_Law_Enforcement le with (nolock)
inner join CT_Law_Enforcement_Agency la with (nolock)
	on la.ID = le.Law_Enforcement_Agency_ID
inner join Asset a with (nolock)
	on a.ID = le.Asset_ID
inner join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
inner join CT_Site s with (nolock)
	on s.ID = am.Site_ID
















GO
