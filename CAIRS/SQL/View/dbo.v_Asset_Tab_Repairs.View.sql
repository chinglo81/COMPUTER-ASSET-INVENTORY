USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Repairs]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[v_Asset_Tab_Repairs]
AS

select 
	r.ID,
	r.Asset_ID,
	s.ID as Asset_Site_ID,
	s.Short_Name as Asset_Site_Desc,
	s.Code as Asset_Site_Code,
	r.Repair_Type_ID,
	rt.Name as Repair_Type_Desc,
	r.Comment,
	r.Date_Sent,
	dbo.FormatDateTime(r.Date_Sent, 'MM/DD/YYYY') as Date_Sent_Formatted,
	r.Date_Received,
	dbo.FormatDateTime(r.Date_Received, 'MM/DD/YYYY') as Date_Received_Formatted,
	r.Received_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(r.Received_By_Emp_ID)) as Received_By_Emp_Name,
	r.Added_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(r.Added_By_Emp_ID)) as Added_By_Emp_Name,
	r.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(r.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	r.Date_Added,
	dbo.FormatDateTime(r.Date_Added, 'MM/DD/YYYY') as Date_Added_Formatted,
	r.Date_Modified,
	dbo.FormatDateTime(r.Date_Modified, 'MM/DD/YYYY') as Date_Modified_Formatted

from Asset_Repair r with (nolock)
inner join Asset a with (nolock)
	on a.ID = r.Asset_ID
inner join Asset_Site_Mapping am with (nolock)
	on am.Asset_ID = a.ID
inner join CT_Site s with (nolock)
	on s.ID = am.Site_ID

left join CT_Repair_Type rt with (nolock)
	on rt.ID = r.Repair_Type_ID















GO
