USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Assign_Asset_To_Bin]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Lo, Ching>
-- Create date: <2017-02-22>
-- Description:	<Validate when assigning asset to a bin>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Assign_Asset_To_Bin]
		@Tag_ID AS VARCHAR(100),
		@Bin_ID AS VARCHAR(100)
AS
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Validation SUMMARY for Student Checkout
--1. Check to see if the tag id exist
--2. Check if the asset site matches the bin site, NOTE: This rule can be bypass if the disposition on the asset allows it to. Check Business Rule.
--3. Cannont assign asset to bin that is still checkout, NOTE: This rule can be bypass if the disposition on the asset allows it to. Check Business Rule.
-----------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @Asset_ID as INT
	SET @Asset_ID = (SELECT ID from Asset where Tag_ID = @Tag_ID and Is_Active = 1)

	--1. Check to see if the tag id exist:
    select 
	    '<li>Tag ID: ' + @Tag_ID + ' not found. Please add this asset before assigning it to a bin</li>' as Error
    from (
	    select count(*) total
	    from Asset a
	    where a.Tag_ID = @Tag_ID
    ) t
    where t.total = 0
                        
    union all                            

    --2. Check if the asset site matches the bin site
    select
	    '<li>Site mismatch. The asset site (' + s.Name + ') does not match this bin site (' + bs.Name + ')</li>' as Error
    from asset a
	inner join CT_Asset_Disposition disp
		on disp.ID = a.Asset_Disposition_ID
    left join Asset_Site_Mapping sm
	    on sm.Asset_ID = a.ID
    left join CT_Site s
	    on s.ID = sm.Site_ID
    cross join Bin b
    left join CT_Site bs
	    on bs.ID = b.Site_ID
	where 1=1 
	    and a.ID = @Asset_ID
	    and b.ID = @Bin_ID
	    and sm.Site_ID <> b.Site_ID
		and disp.Code not in ( --By pass rule if there is no site restriction on the disposition
			select 
				det.Code
			from Business_Rule br
			left join Business_Rule_Detail det
				on det.Business_Rule_ID = br.ID
			where br.Code = 'Disp_No_Site_Bin_Restriction'
		)

    union all

    --3. Disposition Not Allowed to Assign to bin
		--Assigned - 5
		--Lost - 4
		--Stolen - 2
    select 
	    '<li>Cannot assigned asset with disposition: ' + disp.Name + '</li>' as Error
    from Asset a
	inner join CT_Asset_Disposition disp
		on disp.ID = a.Asset_Disposition_ID
    where a.ID = @Asset_ID
		and disp.Code in ( --By pass rule if there is no site restriction on the disposition
			select 
				det.Code
			from Business_Rule br
			left join Business_Rule_Detail det
				on det.Business_Rule_ID = br.ID
			where br.Code = 'Disp_Not_Allow_Bin_Assignment'
		)
    



GO
