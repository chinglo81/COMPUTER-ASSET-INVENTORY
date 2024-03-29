USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Bin]    Script Date: 2/3/2017 10:34:41 AM ******/
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
	cond.Name as Asset_Condition_Desc
from Asset_Bin_Mapping bm
inner join Bin b
	on b.ID = bm.Bin_ID
inner join Asset a
	on a.ID = bm.Asset_ID
left join CT_Asset_Type at
	on at.ID = a.Asset_Type_ID
left join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
left join CT_Asset_Condition cond
	on cond.ID = a.Asset_Condition_ID 





GO
