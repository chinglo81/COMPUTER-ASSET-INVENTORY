USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Law_Enforcement]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[v_Asset_Law_Enforcement]
AS


select 
	--Asset Info
	le.Asset_ID,
	amas.Asset_Site_Code,
	amas.Asset_Site_Desc,
	amas.Tag_ID,
	amas.Asset_Base_Type_Desc,
	amas.Asset_Type_Desc,
	--Law Enforcement Info
	le.ID,
	le.Law_Enforcement_Agency_ID,
	la.Name as Law_Enforcement_Agency_Name,
	la.Short_Name as Law_Enforcement_Agency_Short_Name,
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
inner join v_Asset_Master_List amas with(nolock)
	on amas.Asset_ID = le.Asset_ID


















GO
