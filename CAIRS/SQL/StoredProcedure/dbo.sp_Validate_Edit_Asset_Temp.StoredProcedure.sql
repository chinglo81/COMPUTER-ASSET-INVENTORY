USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Edit_Asset_Temp]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Edit_Asset_Temp]
		@Header_ID AS INT,
		@Bin_ID AS INT
AS

	--Validate if bin is full
    with bin_full as (
	    select
		    '- Site bin is full. Select another bin. Available Capacity for this bin is: ' + cast(b.Capacity - isnull(tot_assign.total_assigned_to_bin, 0) as varchar(10)) as Message_Error
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

    )

    select * from bin_full


GO
