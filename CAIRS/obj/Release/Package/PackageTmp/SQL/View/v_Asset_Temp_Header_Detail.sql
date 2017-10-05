USE [Asset_Tracking]
GO

/****** Object:  View [dbo].[v_Asset_Temp_Header_Detail]    Script Date: 1/20/2017 7:41:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_Asset_Temp_Header_Detail]
AS
	with asset_temp_hdr as (
		select 
			hdr.ID as Header_ID,
			hdr.Name as Group_Name,
			hdr.Description as Group_Description,
			site.Name as Site_Description,
			case when hdr.Has_Submit = 1 then 'Yes' else 'No' end as Has_Submit
		from Asset_Temp_Header hdr
		inner join CT_Site site
			on site.id = hdr.Asset_Site_ID
	),

	asset_temp_det as (
		select
			det.ID as Detail_ID,
			det.Asset_Temp_Header_ID as Header_ID,
			b.Name as BinName,
			at.Name as Asset_Type_Name,
			cond.Name as Asset_Condition_Name,
			disp.Name as Asset_Disposition_Name,
			case when det.Is_Leased = 1 then 'Yes' else 'No' end as Is_Leased,
			det.Serial_Number,
			det.Tag_ID,
			det.Date_Added
		from Asset_Temp_Detail det
		inner join CT_Asset_Type at
			on at.ID = det.Asset_Type_ID
		inner join CT_Asset_Condition cond
			on cond.ID = det.Asset_Condition_ID
		inner join CT_Asset_Disposition disp
			on disp.ID = det.Asset_Disposition_ID
		left join Bin b
			on b.ID = det.Bin_ID
	)

	select 
		h.Group_Name,
		h.Group_Description,
		h.Site_Description,
		h.Has_Submit,
		d.*
	from asset_temp_hdr h
	left join asset_temp_det d
		on d.Header_ID = h.Header_ID



GO


