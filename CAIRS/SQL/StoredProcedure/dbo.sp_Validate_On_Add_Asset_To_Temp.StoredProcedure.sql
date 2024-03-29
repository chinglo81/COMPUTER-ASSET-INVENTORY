USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_On_Add_Asset_To_Temp]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_On_Add_Asset_To_Temp]
		@Header_ID AS INT,
		@Tag_ID AS VARCHAR(100),
		@Serial_Number AS VARCHAR(100),
		@Bin_ID AS INT, 
		@Is_Leased AS VARCHAR(1),
		@Asset_Type_ID AS VARCHAR(10)
AS

	with asset_temp_dup_tag as (
	    select 
		    'ERROR: You already have an asset with Tag ID "' + @Tag_ID + '".'  as Message_Error
	    from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
        left join Asset a
	    on a.Tag_ID = d.Tag_ID

	    where 1=1
		    and h.ID = @Header_ID
		    and d.Tag_ID = @Tag_ID
            and a.ID is null

	    group by
		    d.Tag_ID
    ),

    asset_dup_tag as (
	    select 
		    'ERROR: An asset with Tag ID: ' + @Tag_ID + ' has already been submitted.' as Message_Error
	    from Asset
	    where Is_Active = 1
	    and Tag_ID = @Tag_ID
    ),

	asset_temp_dup_serial as (
	    select 
		    'ERROR: You already have an asset with Serial Number: "' + @Serial_Number + '".'  as Message_Error
	    from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
        left join Asset a
	    on a.Serial_Number = d.Serial_Number

	    where 1=1
		    and h.ID = @Header_ID
		    and d.Serial_Number = @Serial_Number
            and a.ID is null

	    group by
		    d.Tag_ID
    ),

	asset_dup_serial as (
	    select 
		    'ERROR: An asset with Serial Number:' + @Serial_Number + ' has already been submitted.' as Message_Error
	    from Asset
	    where Serial_Number = @Serial_Number
    ),

    bin_full as (
	    select
		    --'ERROR: Site bin is full. Select another bin. Available Capacity for this bin is: ' + cast(b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0) as varchar(10)) as Message_Error
			'ERROR: Site bin is full. Select another bin.' as Message_Error
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
		    and b.ID = @Bin_ID
	    group by
		    tot_assign.total_assigned_to_bin,
		    b.Capacity,
		    d.Bin_ID
	    having count(*) >= (b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0)) --Note: This is different submit because the total has to be greater than or equal 

    ), 

	validate_tag_id_leased as (
		select 
			'Tag ID must start with "M" for Leased ' + bt.Name as Message_Error
		from CT_Asset_Type ct
		inner join CT_Asset_Base_Type bt
			on bt.ID = ct.Asset_Base_Type_ID
		where 1=1
			and @Is_Leased = '1'
			and bt.ID = 1 --Laptop base type
			and ct.ID = @Asset_Type_ID
			and @Tag_ID not like 'm%'
	), 

	validate_tag_id_length as (
		select 
			'Tag ID must be "10" character for Leased ' + bt.Name as Message_Error
		from CT_Asset_Type ct
		inner join CT_Asset_Base_Type bt
			on bt.ID = ct.Asset_Base_Type_ID
		where 1=1
			and @Is_Leased = '1'
			and bt.ID = 1 --Laptop base type'
			and ct.ID = @Asset_Type_ID
			and len(@Tag_ID) <> 10
	),

	validate_tag_match_serial_for_power_adapter as (
		select 
			'Tag ID and Serial # must match for ' +  bt.Name as Message_Error
		from CT_Asset_Type at
		inner join CT_Asset_Base_Type bt
			on bt.ID = at.Asset_Base_Type_ID
		where 1=1
			and at.ID = @Asset_Type_ID
			and bt.ID = 3 --Power Adapter
			and @Tag_ID <> @Serial_Number
			and at.ID = @Asset_Type_ID
	)

    select * from asset_temp_dup_tag
    union 
    select * from asset_dup_tag
    union
	select * from asset_temp_dup_serial
    union 
    select * from asset_dup_serial
    union
    select * from bin_full
	union 
	select * from validate_tag_id_leased
	union 
	select * from validate_tag_id_length
	union 
	select * from validate_tag_match_serial_for_power_adapter


GO
