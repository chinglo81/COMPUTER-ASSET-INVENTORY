USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetUserSiteSecurity]    Script Date: 10/5/2017 11:35:07 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetUserSiteSecurity](@Network_Login varchar(100)) RETURNS TABLE
--returns list of sites user have access to for cairs
AS
return (

--Sites 
with sites as (
	select 
		s.Code as Mapping_Code,
		s.Code, 
		s.Name, 
		s.Is_Active 
	from CT_Site s --all site
	
	union all
	
	select 
		s.Code as Mapping_Code,
		sm.code, 
		sm.name, 
		sm.Is_Active 
	from CT_Site_Mapping sm
	inner join CT_Site s
		on s.ID = sm.CT_Site_ID
)

--All Sites
select
	asset_site.Code as Site_Code,
	asset_site.Name as Site_Desc
from security.dbo.AppUsers u
inner join security.dbo.Apps app
	on app.ID = u.AppID
cross join sites asset_site

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
inner join sites asset_site
	on dbo.PadLeft(asset_site.Mapping_Code, 4, '0') = dbo.PadLeft(e.PrimaryWorkLocation, 4, '0')
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
inner join sites asset_site
	on dbo.PadLeft(asset_site.Mapping_Code, 4, '0') = dbo.PadLeft(s.sitecode, 4,'0')
where app.AppName = 'CAIRS'
	and asset_site.Is_Active = 1
	and u.includedsites = 3
	and u.NetworkLogin = @Network_Login
)

GO
