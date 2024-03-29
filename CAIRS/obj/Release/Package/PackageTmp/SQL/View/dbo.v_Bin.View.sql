USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Bin]    Script Date: 2/3/2017 10:34:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [dbo].[v_Bin]
AS

--Get Total Asset Count by Bin
with Bin_Asset_Count as (
	select 
		bm.Bin_ID,
		count(*) as Asset_Count
	from Asset_Bin_Mapping bm
	inner join Asset a
		on a.ID = bm.Asset_ID
	group by
		bm.Bin_ID
)

select 
	b.ID as Bin_ID,
	b.Site_ID,
	s.Name as Site_Name,
	s.Description as Site_Description,
	b.Number,
	b.Description as Bin_Description,
	left(b.Description, 30) + case when len(b.Description) > 30 then '...more' else '' end as Bin_Description_Short,
	b.Capacity,
	b.Is_Active,
	case when b.Is_Active = 1 then 'Yes' else 'No' end as Is_Active_Desc,
	b.Added_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(b.Added_By_Emp_ID)) as Added_By_Emp_Name,
	b.Date_Added,
	b.Modified_By_Emp_ID,
	dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(b.Modified_By_Emp_ID)) as Modified_By_Emp_Name,
	b.Date_Modified,
	isnull(tot.Asset_Count, 0) as Asset_Count,
	b.Capacity - isnull(tot.Asset_Count, 0) as Available_Capacity
from Bin b
left join CT_Site s
	on s.ID = b.Site_ID
left join Bin_Asset_Count tot
	on tot.Bin_ID = b.ID











GO
