USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Tab_Changes]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[v_Asset_Tab_Changes]
AS


select
	aud.ID,
	case 
		when aud.Table_Name = 'Asset_Bin_Mapping' then bm.Asset_ID
		when aud.Table_Name = 'Asset_Site_Mapping' then sm.Asset_ID
		else
			aud.Primary_Key_ID
	end as Asset_ID,
	aud.Column_Name,
	aud.Column_Name_Desc,
	aud.Old_Value,
	aud.Old_Value_Desc,
	aud.New_Value,
	aud.New_Value_Desc,
	isnull(dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(aud.Emp_ID)),aud.Emp_ID) as Modified_By_Emp_Name,
	dbo.FormatDateTime(aud.Date_Modified, 'MM/DD/YYYY') as Date_Modified_Formatted,
	aud.Date_Modified
from Audit_Log aud with (nolock)
left join Asset_Bin_Mapping bm with (nolock)
	on bm.ID = aud.Primary_Key_ID
	and aud.Table_Name = 'Asset_Bin_Mapping'
left join Asset_Site_Mapping sm with (nolock)
	on sm.ID = aud.Primary_Key_ID
	and aud.Table_Name = 'Asset_Site_Mapping'








GO
