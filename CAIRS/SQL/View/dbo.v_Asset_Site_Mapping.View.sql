USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Site_Mapping]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[v_Asset_Site_Mapping]
AS

	select 
		s.ID as CT_Site_ID,
		s.Code as Mapping_Code,
		s.Code, 
		s.Name, 
		s.Is_Active 
	from CT_Site s with(nolock) --all site 
	
	union
	
	select 
		sm.CT_Site_ID,
		s.Code as Mapping_Code,
		sm.code, 
		sm.name, 
		sm.Is_Active 
	from CT_Site_Mapping sm with(nolock)
	inner join CT_Site s with(nolock)
		on s.ID = sm.CT_Site_ID







GO
