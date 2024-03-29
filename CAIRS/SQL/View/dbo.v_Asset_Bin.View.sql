USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Bin]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[v_Asset_Bin]
AS


select 
	bm.Bin_ID,
	bm.Asset_ID,
	a.Tag_ID,
	a.Asset_Type_ID,
	at.Name as Asset_Type_Desc,
	a.Asset_Disposition_ID,
	disp.Name as Asset_Disposition_Desc,
	a.Asset_Condition_ID,
	cond.Name as Asset_Condition_Desc,
	sm.Site_ID as Asset_Site_ID,
	s.Short_Name as Asset_Site_Desc,
	s.Code as Asset_Site_Code,
	b.Site_ID as Bin_Site_ID,
	bin_site.Code as Bin_Site_Code,
	bin_site.Name as Bin_Site_Desc

from Asset_Bin_Mapping bm with (nolock)
inner join Bin b with (nolock)
	on b.ID = bm.Bin_ID
inner join CT_Site bin_site
	on bin_site.ID = b.Site_ID
inner join Asset a with (nolock)
	on a.ID = bm.Asset_ID
left join Asset_Site_Mapping sm with (nolock)
	on sm.Asset_ID = a.ID
left join CT_Site s with (nolock)
	on s.ID = sm.Site_ID 
left join CT_Asset_Type at with (nolock)
	on at.ID = a.Asset_Type_ID
left join CT_Asset_Disposition disp with (nolock)
	on disp.ID = a.Asset_Disposition_ID
left join CT_Asset_Condition cond with (nolock)
	on cond.ID = a.Asset_Condition_ID 













GO
