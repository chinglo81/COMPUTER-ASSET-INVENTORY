USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_User_Security_Info]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[v_User_Security_Info]
AS

select 
	u.NetworkLogin,
	a.ID as App_ID,
	a.AppName,
	r.RoleName,
	u.isadmin as Is_Security_Admin,
	r.AccessLevel,
	u.includedsites,
	CASE 
		when u.includedsites = 1 then 'All Site'
		when u.includedsites = 2 then 'Work Location Only'
		else 'Custom'
	End as Sites_Access,
	u.ExpirationDate,
	u.allsites,
    asset_tracking.dbo.GetSecuritySiteByUserId(u.NetworkLogin, ',') as User_Access_Site,
	asset_tracking.dbo.GetSecuritySiteDescByUserId(u.NetworkLogin, '<br/>') User_Access_Site_Desc
from security.dbo.Apps a with (nolock)
inner join security.dbo.AppUsers u with (nolock)
	on u.AppID = a.ID
inner join security.dbo.AppRoles r with (nolock)
	on r.id = u.roleid
where 1=1
	and a.AppName = 'CAIRS'
    and isnull(u.ExpirationDate, GETDATE()) >= cast(GETDATE() as date)




GO
