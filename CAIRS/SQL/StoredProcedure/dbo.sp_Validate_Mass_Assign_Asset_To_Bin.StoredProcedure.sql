USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Mass_Assign_Asset_To_Bin]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Mass_Assign_Asset_To_Bin]
	@Asset_Search_ID int,
	@Bin_ID int
AS

--Must have at least one item selected
select 'You must selected as least one asset from the grid.' as Error_Msg
from 
(
	select 
		count(*) total
	from Asset_Search_Detail d
	where d.Asset_Search_ID = @Asset_Search_ID
	and d.Is_Checked = 1 
) tbl
where tbl.total = 0

union all

--Must have matching asset site (excluding disposition with site restrictions)
select 'The selected asset(s) must belong to only one site.' as Error_Msg
from 
(
	select count(*) total
	from ( 
		select 
			am.Site_ID
		from Asset_Search h
		inner join Asset_Search_Detail d
			on d.Asset_Search_ID = h.ID
		inner join Asset a
			on a.ID = d.Asset_ID
		inner join CT_Asset_Disposition disp
			on disp.ID = a.Asset_Disposition_ID
		inner join Asset_Site_Mapping am
			on am.Asset_ID = d.Asset_ID
		where 1=1
			and h.ID = @Asset_Search_ID
			and d.Is_Checked = 1
			and disp.code not in (
				select --Exclude business disposition that does not have site restrictions
					d.Code
				from Business_Rule br
				inner join Business_Rule_Detail d
					on d.Business_Rule_ID = br.ID
				where br.Code in (
					'Disp_No_Site_Bin_Restriction'
				)
			)
		group by
			am.Site_ID

	) t
) tbl
where tbl.total > 1

union all

--Check to see if the site bin is available to hold the selected asset
select 'Too many asset(s) selected. Available capacity is ' + cast(tbl.available_capacity as varchar(100)) + '. You selected ' + cast(tbl.asset_to_assign as varchar(100)) + ' asset(s).'as Error_Msg
from (
	select 
		b.id as Bin_ID,
		isnull(used_bin.total_used, 0) as total_used,
		b.Capacity - isnull(used_bin.total_used, 0) as available_capacity,
		(
			select count(*)
			from Asset_Search_Detail d
			where 1=1
				and d.Asset_Search_ID = @Asset_Search_ID
				and d.Is_Checked = 1
		) as asset_to_assign
	from Bin b
	left join (
		select
			bm.Bin_ID,
			count(*) as total_used
		from Asset_Bin_Mapping bm
		group by
			bm.Bin_ID
	) used_bin
	on b.ID = used_bin.Bin_ID
) tbl
where tbl.Bin_ID = @Bin_ID
and tbl.asset_to_assign > tbl.available_capacity

union all

select distinct
	    'Cannot assign checked-out asset(s) to a bin.' as Error
from Asset_Search h
inner join Asset_Search_Detail d
	on d.Asset_Search_ID = h.ID
inner join Asset a
	on a.ID = d.Asset_ID
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
inner join Asset_Student_Transaction astu
	on astu.Asset_ID = a.id
where 1=1
	and h.ID = @Asset_Search_ID
	and d.Is_Checked = 1
	and disp.code not in (
		select --Exclude business disposition that does not have site restrictions
			d.Code
		from Business_Rule br
		inner join Business_Rule_Detail d
			on d.Business_Rule_ID = br.ID
		where br.Code in (
			'Disp_No_Site_Bin_Restriction'
		)
	)
	and astu.Date_Check_In is null
GO
