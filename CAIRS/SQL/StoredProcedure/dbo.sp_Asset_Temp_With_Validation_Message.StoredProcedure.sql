USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Asset_Temp_With_Validation_Message]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[sp_Asset_Temp_With_Validation_Message]
		@HeaderID AS INT
AS
	--Validate Duplicate Tag ID within the batch
    with validation_asset_temp_dup as (
	    select 
		    d.Tag_ID,
		    '<li>Duplicate <strong>Tag ID</strong> - Remove one from your list</li>' as Message_Error
	    from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
	    where 1=1
		    and h.ID = @HeaderID
	    group by
		    d.Tag_ID
	    having count(*) >= 2
    ),

    --Validate Duplicate Tag ID in Asset table
    validation_asset_dup as (
	    select 
		    Tag_ID,
		    '<li><strong>Tag ID:</strong> ' + Tag_ID + ' already submitted</li>' as Message_Error
	    from Asset
    ),

    --Validate Duplicate Serial Number within the batch
    validation_asset_temp_dup_serial as (
	    select 
		    d.Serial_Number,
		    '<li>Duplicate <strong>Serial Number</strong> - Remove one from your list</li>' as Message_Error
	    from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
	    where 1=1
		    and h.ID = @HeaderID
	    group by
		    d.Serial_Number
	    having count(*) >= 2
    ),

    --Validate Duplicate Tag ID in Asset table
    validation_serial_dup as (
	    select 
		    d.Serial_Number,
		    '<li><strong>Serial Number:</strong> ' + d.Serial_Number + ' already submitted</li>' as Message_Error
	    from Asset a
	    inner join Asset_Temp_Detail d
		    on d.Serial_Number = a.Serial_Number
	    where 
		    d.Asset_Temp_Header_ID = @HeaderID
    ),

    --Validate Site Bin vs Site Asset
    validation_site_bin as (
	    select
		    d.Tag_ID,
		    '<li><strong>Site bin</strong> mismatch. Select another bin that matches the site asset</li>' as Message_Error
	    from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
	    inner join Bin b
		    on b.ID = d.Bin_ID
	    where 1=1
		    and h.ID = @HeaderID
		    and b.Site_ID <> h.Asset_Site_ID
	    group by
		    d.Tag_ID
    ),

    --Validate if bin is full
    validation_site_bin_full as (
	    select
		    d.Bin_ID,
		    tot_assign.total_assigned_to_bin,
		    b.Capacity,
		    b.Capacity - tot_assign.total_assigned_to_bin as avail_cap, 
		    '<li><strong>Site bin</strong> is full. Available Capacity for this bin is: ' + cast(b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0) as varchar(10)) + '. You have: ' + cast(count(*) as varchar(10)) + '</li>' as Message_Error,
		    count(*) as total
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
		    and h.ID = @HeaderID
		    and b.Site_ID = h.Asset_Site_ID
	    group by
		    tot_assign.total_assigned_to_bin,
		    b.Capacity,
		    d.Bin_ID
	    having count(*) > (b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0))
	
    ),

	validate_tag_id_leased as (
		select 
			d.Tag_ID,
			'<li><strong>Tag ID</strong> must start with "M" for Leased ' + bt.Name + '</li>' as Message_Error
		from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
		inner join CT_Asset_Type at
			on at.ID = d.Asset_Type_ID
		inner join CT_Asset_Base_Type bt
			on bt.ID = at.Asset_Base_Type_ID
		where 1=1
			and h.ID = @HeaderID
			and d.Is_Leased = '1'
			and bt.ID = 1 --Laptop base type
			and d.Tag_ID not like 'm%'
	), 

	validate_tag_id_length as (
		select 
			d.Tag_ID,
			'<li><strong>Tag ID</strong> must be "10" character for Leased ' + bt.Name + '</li>' as Message_Error
		from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
		inner join CT_Asset_Type at
			on at.ID = d.Asset_Type_ID
		inner join CT_Asset_Base_Type bt
			on bt.ID = at.Asset_Base_Type_ID
		where 1=1
			and h.ID = @HeaderID
			and d.Is_Leased = '1'
			and bt.ID = 1 --Laptop base type
			and len(d.Tag_ID) <> 10
	),

	validate_tag_match_serial_for_power_adapter as (
		select 
			d.Tag_ID,
			'<li><strong>Tag ID</strong> must match <strong>Serial #</strong> for ' + bt.Name + '</li>' as Message_Error
		from Asset_Temp_Header h
	    inner join Asset_Temp_Detail d
		    on d.Asset_Temp_Header_ID = h.ID
		inner join CT_Asset_Type at
			on at.ID = d.Asset_Type_ID
		inner join CT_Asset_Base_Type bt
			on bt.ID = at.Asset_Base_Type_ID
		where 1=1
			and h.ID = @HeaderID
			and bt.ID = 3 --power adapter
			and d.Tag_ID <> d.Serial_Number
	),

    get_validation_group_by_tag as (
	    select * from validation_asset_temp_dup
	    union all
	    select * from validation_asset_dup
	    union all 
	    select * from validation_site_bin
		union all
		select * from validate_tag_id_leased
		union all
		select * from validate_tag_id_length
		union all
		select * from validate_tag_match_serial_for_power_adapter

    ),

    get_validation_group_by_serial as (
	    select * from validation_asset_temp_dup_serial
	    union all
	    select * from validation_serial_dup
    ),

    get_single_line_message_by_tag as (
	    select t.Tag_ID,
			    (
				    select stuff(
				    (select '; ' + Message_Error
				    from get_validation_group_by_tag
				    where Tag_ID = t.Tag_ID
				    FOR XML PATH ('')), 1, 1, '')
			    ) as Error_Msg
	    from get_validation_group_by_tag t
	    group by
		    Tag_ID
    ),

    get_single_line_message_by_serial as (
	    select t.Serial_Number,
			    (
				    select stuff(
				    (select '; ' + Message_Error
				    from get_validation_group_by_serial
				    where Serial_Number = t.Serial_Number
				    FOR XML PATH ('')), 1, 1, '')
			    ) as Error_Msg
	    from get_validation_group_by_serial t
	    group by
		    t.Serial_Number
    )

    select
	    distinct
	    v.*,
		case 
			when v.Has_Submit = 'yes' then '' 
			else isnull(msg.Error_Msg,'') + isnull(ser_msg.Error_Msg,'') 
		end as Message_Error  

    from v_Asset_Temp_Header_Detail v
    left join (
	    select
		    t.Tag_ID,
		    case when t.Error_Msg is not null 
			    then 
				    replace(replace(replace(t.Error_Msg, '&lt;','<'),'&gt;','>'),';', '') + '' 
			    else '' 
		    end Error_Msg
	    from get_single_line_message_by_tag t

    ) msg
	    on msg.Tag_ID = v.Tag_ID
    left join (
	    select
		    s.Serial_Number,
		    case when s.Error_Msg is not null 
			    then 
				    replace(replace(s.Error_Msg, '&lt;','<'),'&gt;','>') + '' 
			    else '' 
		    end Error_Msg
	    from get_single_line_message_by_serial s
    ) ser_msg
	    on ser_msg.Serial_Number = v.Serial_Number
    left join validation_site_bin_full b
	    on b.Bin_ID = v.Bin_ID
    where v.Header_ID = @HeaderID
    order by v.Date_Added desc
GO
