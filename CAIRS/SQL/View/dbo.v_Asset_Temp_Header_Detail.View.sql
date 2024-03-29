USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Temp_Header_Detail]    Script Date: 10/5/2017 11:32:04 AM ******/
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
			site.Code as Site_Code,
			case when hdr.Has_Submit = 1 then 'Yes' else 'No' end as Has_Submit
		from Asset_Temp_Header hdr with (nolock)
		inner join CT_Site site with (nolock)
			on site.id = hdr.Asset_Site_ID
	),

	asset_temp_det as (
		select
			det.ID as Detail_ID,
			det.Asset_Temp_Header_ID as Header_ID,
			b.ID as Bin_ID,
			b.Number as Bin_Number,
			at.Name as Asset_Type_Name,
			cond.Name as Asset_Condition_Name,
			disp.Name as Asset_Disposition_Name,
			case when det.Is_Leased = 1 then 'Yes' else 'No' end as Is_Leased,
			det.Serial_Number,
			det.Tag_ID,
			det.Date_Added,
			det.Date_Purchased,
			dbo.FormatDateTime(det.Date_Purchased,'MM/DD/YYYY') as Date_Purchased_Formatted,
			det.Leased_Term_Days,
			det.Warranty_Term_Days
		from Asset_Temp_Detail det with (nolock)
		inner join CT_Asset_Type at with (nolock)
			on at.ID = det.Asset_Type_ID
		inner join CT_Asset_Condition cond with (nolock)
			on cond.ID = det.Asset_Condition_ID
		inner join CT_Asset_Disposition disp with (nolock)
			on disp.ID = det.Asset_Disposition_ID
		left join Bin b with (nolock)
			on b.ID = det.Bin_ID
	)

	select 
		h.Group_Name,
		h.Group_Description,
		h.Site_Description,
		h.Site_Code,
		h.Has_Submit,
		d.*
	from asset_temp_hdr h with (nolock)
	left join asset_temp_det d with (nolock)
		on d.Header_ID = h.Header_ID












GO
