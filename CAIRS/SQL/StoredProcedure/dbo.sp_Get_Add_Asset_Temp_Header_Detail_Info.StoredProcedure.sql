USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_Add_Asset_Temp_Header_Detail_Info]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Get_Add_Asset_Temp_Header_Detail_Info]
		@ID AS INT
AS

	with MostRecentDate as (
		select max(a.MostRecentDate) as MostRecentDate
		from (
			select Date_Added as MostRecentDate from Asset_Temp_Header where id = @ID
			union all
			select Date_Modified from Asset_Temp_Header where id = @ID
			union all
			select Date_Added from Asset_Temp_Detail where Asset_Temp_Header_ID = @ID
		) a
	),

	MostRecentDetail as (
		select max(ID) as Detail_ID from Asset_Temp_Detail where Asset_Temp_Header_ID = @ID
	),

	HasAssetInBin as (
		select 
			d.Asset_Temp_Header_ID,
			1 HasBin 
		from Asset_Temp_Detail d
		where 1=1 
			and d.Asset_Temp_Header_ID = @ID
			and d.Bin_ID is not null
		group by
			d.Asset_Temp_Header_ID
	)


	select 
		h.ID as Asset_Temp_Header_ID,
		h.Asset_Site_ID,
		s.Name as Asset_Site_Desc,
		s.Code as Asset_Site_Code,
		dbo.FormatDateTime(d.MostRecentDate, 'MM/DD/YYYY HH:MM AM/PM') as UpdateDate,
		h.Description,
		h.Has_Submit,
		det.Detail_ID,
		atd.Bin_ID,
		atd.Asset_Type_ID,
		bt.ID as Asset_Base_Type_ID,
		bt.Name as Asset_Base_Type_Desc,
		atd.Asset_Condition_ID,
		atd.Asset_Disposition_ID,
		atd.Is_Leased,
		dbo.FormatDateTime(atd.Date_Purchased, 'MM/DD/YYYY') as Date_Purchased,
		atd.Leased_Term_Days,
		atd.Warranty_Term_Days,
		isnull(hb.HasBin, 0) as HasAssetInBin
                            
	from Asset_Temp_Header h
	inner join CT_Site s
		on s.ID = h.Asset_Site_ID
	cross join MostRecentDate d 
	cross join MostRecentDetail det  
	left join Asset_Temp_Detail atd 
		on det.Detail_ID = atd.ID
    left join HasAssetInBin hb
		on hb.Asset_Temp_Header_ID = h.ID
	left join CT_Asset_Type at
		on at.ID = atd.Asset_Type_ID
	left join CT_Asset_Base_Type bt
		on bt.ID = at.Asset_Base_Type_ID
	                
	where h.ID = @ID

	group by
		h.ID,
		h.Asset_Site_ID,
		s.Name,
		s.Code,
		d.MostRecentDate,
		h.Description,
		det.Detail_ID,
		atd.Bin_ID,
		atd.Asset_Type_ID,
		atd.Asset_Condition_ID,
		atd.Asset_Disposition_ID,
		atd.Is_Leased,
		h.Has_Submit,
		hb.HasBin,
		atd.Date_Purchased,
		atd.Leased_Term_Days,
		atd.Warranty_Term_Days,
		bt.ID,
		bt.Name

	order by UpdateDate desc

GO
