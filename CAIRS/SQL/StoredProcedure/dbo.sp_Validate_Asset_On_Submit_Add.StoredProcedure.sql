USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Asset_On_Submit_Add]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Asset_On_Submit_Add]
		@Header_ID AS INT
AS

	--Validate Duplicate Tag ID within the batch
    select 
	    'Unable to submit because of duplicate Tag_ID: ' + d.Tag_ID + ' in your list. Please remove one of them.' as Message_Error
    from Asset_Temp_Detail d
    left join Asset a
	    on a.Tag_ID = d.Tag_ID
	    and a.Is_Active = 1
    where d.Asset_Temp_Header_ID = @Header_ID
	    and a.ID is null
    group by
	    d.Tag_ID
    having count(*) > 1

    union all
                            
    --Validate Duplicate Tag ID in Asset table
    select 
	    'Tag_ID: ' + a.Tag_ID + ' has already been submitted. Please remove from your list.' AS Message_Error
    from Asset_Temp_Header hdr
    inner join Asset_Temp_Detail det
	    on det.Asset_Temp_Header_ID = hdr.ID
    inner join Asset a
	    on a.Tag_ID = det.Tag_ID
	    and a.Is_Active = 1
    where hdr.ID = @Header_ID

    union all

    --Validate Site Bin vs Site Asset
    select
		'Site bin mismatch. Select another bin that matches the site asset.' as Message_Error
	from Asset_Temp_Header h
	inner join Asset_Temp_Detail d
		on d.Asset_Temp_Header_ID = h.ID
	inner join Bin b
		on b.ID = d.Bin_ID
	where 1=1
		and h.ID = @Header_ID
		and b.Site_ID <> h.Asset_Site_ID
	group by
		d.Tag_ID

    union all

    --Validate if bin is full
    select
		'Site bin is full. Select another bin. Available Capacity for this bin is: ' + cast(b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0) as varchar(10)) as Message_Error
	from Asset_Temp_Header h
	inner join Asset_Temp_Detail d
		on d.Asset_Temp_Header_ID = h.ID
	inner join Bin b
		on b.ID = d.Bin_ID
	left join (
		select
			Bin_ID,
			count(*) as total_assigned_to_bin
		from Asset_Bin_Mapping 
		group by Bin_ID
	) tot_assign
		on tot_assign.Bin_ID = b.ID
	where 1=1
		and h.ID = @Header_ID
		and b.Site_ID = h.Asset_Site_ID
	group by
		tot_assign.total_assigned_to_bin,
		b.Capacity,
		d.Bin_ID
	having count(*) > (b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0))


GO
