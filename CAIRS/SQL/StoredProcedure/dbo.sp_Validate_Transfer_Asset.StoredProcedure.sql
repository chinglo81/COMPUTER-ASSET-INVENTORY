USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Transfer_Asset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Transfer_Asset]
		@Asset_Search_ID AS INT,
		@Transfer_Site_ID AS INT
AS

	--Validate disposition
    with asset_search_selected as (
	    select 
		    v.*
	    from Asset_Search_Detail d with (nolock)
	    inner join v_Asset_Master_List v with (nolock)
	    on v.Asset_ID = d.Asset_ID

	    where 1=1
		    and d.Asset_Search_ID = @Asset_Search_ID
		    and d.Is_Checked = 1 
    ),

    invalid_disposition as (     
	    select 
		    v.Tag_ID,
		    'Invalid disposition for transfer: ' + v.Asset_Disposition_Desc as Message_Error
	    from asset_search_selected v
	    where 1=1
		    and v.Allow_Transfer = 0
    ),

    TransferSite_AssetSite_Match as (
	    select 
		    v.Tag_ID,
		    'Asset Site matches Transfer Site' as Message_Error
	    from asset_search_selected v
	    where 1=1
		    and v.Asset_Site_ID = @Transfer_Site_ID
    )

    select
	    v.*,
	    case 
		    when invalid_disp.Tag_ID is not null then
			    '<li>' + invalid_disp.Message_Error + '</li>'
		    else
			    ''
	    end +
	    case 
		    when invalid_site.Tag_ID is not null then
			    '<li>' + invalid_site.Message_Error + '</li>'
		    else
			    ''
	    end as Message_error 
    from asset_search_selected v
    left join invalid_disposition invalid_disp
	    on invalid_disp.Tag_ID = v.Tag_ID
    left join TransferSite_AssetSite_Match invalid_site
	    on invalid_site.Tag_ID = v.Tag_ID 

	where invalid_disp.Tag_ID is not null or invalid_site.Tag_ID is not null


GO
