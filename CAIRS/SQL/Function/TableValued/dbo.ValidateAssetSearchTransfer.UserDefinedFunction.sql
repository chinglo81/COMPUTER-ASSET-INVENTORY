USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[ValidateAssetSearchTransfer]    Script Date: 10/5/2017 11:35:07 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[ValidateAssetSearchTransfer](
	@Asset_Search_ID int, 
	@Transfer_Site_ID int,
	@Asset_ID int
) RETURNS TABLE

AS
return (
	--Validate disposition
	with asset_search_selected as (
		select distinct
			v.*
		from v_Asset_Master_List v
		left join  Asset_Search_Detail d 
		on v.Asset_ID = d.Asset_ID

		where 1=1
			and d.Is_Checked = case when @Asset_Search_ID is not null then 1 else d.Is_Checked end
			and d.Asset_Search_ID = isnull(@Asset_Search_ID, d.Asset_Search_ID) 
			and v.Asset_ID = isnull(@Asset_ID, v.Asset_ID)
	),

	invalid_disposition as (     
		select 
			v.Asset_ID,
			'Invalid disposition for transfer: ' + v.Asset_Disposition_Desc as Message_Error
		from asset_search_selected v
		where 1=1
			and v.Allow_Transfer = 0
	),

	TransferSite_Not_Exist as (
		select 
			selected_asset.Asset_ID,
			case 
				when t.total = 0 and @Transfer_Site_ID = -1 then 'Please select a Transfer Site'
				when t.total = 0 then 'Transfer Site ID: ' + cast(@Transfer_Site_ID as varchar(100)) + ' does not exist.' 
				else null
			end as Message_Error
		from asset_search_selected selected_asset 
		cross join (
			select count(*) total
			from CT_Site s
			where s.ID = @Transfer_Site_ID
		) t
	),

	TransferSite_AssetSite_Match as (
		select 
			v.Asset_ID,
			'Asset Site matches Transfer Site' as Message_Error
		from asset_search_selected v
		where 1=1
			and v.Asset_Site_ID = @Transfer_Site_ID
	)


	select 
		selected_asset.Asset_ID,
		case 
			when in_disp.Message_Error is not null then
				'<li>' + in_disp.Message_Error + '</li>'
			else
				''
		end +
		case 
			when transfer_site_exist.Message_Error is not null then
				'<li>' + transfer_site_exist.Message_Error + '</li>'
			else
				''
		end +
		case 
			when site_match.Message_Error is not null  then
				'<li>' + site_match.Message_Error + '</li>'
			else
				''
		end  as Message_error 
	from asset_search_selected selected_asset
	left join invalid_disposition in_disp
		on in_disp.Asset_ID = selected_asset.Asset_ID
	left join TransferSite_Not_Exist transfer_site_exist
		on transfer_site_exist.Asset_ID = selected_asset.Asset_ID
	left join TransferSite_AssetSite_Match site_match
		on site_match.Asset_ID = selected_asset.Asset_ID

	where 1=1
		and in_disp.Message_Error is not null or transfer_site_exist.Message_Error is not null or site_match.Message_Error is not null
)

GO
