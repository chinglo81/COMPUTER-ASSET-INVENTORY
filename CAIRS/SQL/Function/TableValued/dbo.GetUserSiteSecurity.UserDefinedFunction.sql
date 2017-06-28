USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetUserSiteSecurity]    Script Date: 6/28/2017 11:04:40 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetUserSiteSecurity](@Network_Login varchar(100)) RETURNS TABLE
--returns list of sites user have access to for cairs
AS
return (
--All Sites
select
	asset_site.code as Site_Code,
	asset_site.Name as Site_Desc
from security.dbo.AppUsers u
inner join security.dbo.Apps app
	on app.ID = u.AppID
cross join CT_Site asset_site
where app.AppName = 'CAIRS'
	and u.includedsites = 1
	and asset_site.Is_Active = 1
	and u.NetworkLogin = @Network_Login

union

--Work Location
select
	asset_site.Code as Site_Code,
	asset_site.Name as Site_Desc
from security.dbo.AppUsers u
inner join security.dbo.Apps app
	on app.ID = u.AppID
inner join Datawarehouse.dbo.Employees e
	on e.emailaddress = u.NetworkLogin + '@monet.k12.ca.us'
inner join CT_Site asset_site
	on dbo.PadLeft(asset_site.Code,4,'0') = e.PrimaryWorkLocation
where app.AppName = 'CAIRS'
	and asset_site.Is_Active = 1
	and u.includedsites = 2
	and u.NetworkLogin = @Network_Login

union 

--Custom Site
select 
	asset_site.code as Site_Code,
	asset_site.Name as Site_Desc
from security.dbo.AppUsers u
inner join security.dbo.Apps app
	on app.ID = u.AppID
inner join Datawarehouse.dbo.Employees e
	on e.emailaddress = u.NetworkLogin + '@monet.k12.ca.us'
inner join security.dbo.AppUserSites s
	on s.appuserid = u.id
inner join CT_Site asset_site
	on dbo.PadLeft(asset_site.Code,4,'0') = s.sitecode
where app.AppName = 'CAIRS'
	and asset_site.Is_Active = 1
	and u.includedsites = 3
	and u.NetworkLogin = @Network_Login
)

GO
