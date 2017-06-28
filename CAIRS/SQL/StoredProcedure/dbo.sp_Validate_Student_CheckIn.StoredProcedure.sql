USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Student_CheckIn]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Student_CheckIn]
		@Check_In_Site_ID int,
		@Student_ID as varchar(20),
		@Tag_ID as varchar(100)
AS
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Validation SUMMARY for Student Checkout
--1. Student is not active
--2. Student is not highschool grade level
--3. Student Site mistmatch Asset Site
--4. Check agains CT_BaseType Max_Check_Out and (Asset_CheckOut_Exception_Student_Header,Asset_CheckOut_Exception_Student_Detail) Tables
--5. Check to see if the tag exist
--6. Check to see if the tag is inactive
--7. Check to see if asset disposition is allowed to be checkout
-----------------------------------------------------------------------------------------------------------------------------------------------------
--1. Student is not active
select *
from Asset a
inner join Asset_Student_Transaction astu
	on astu.Asset_ID = a.ID
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
inner join (
	select 
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_CheckIn'
		and b.Table_Name = 'CT_Asset_Disposition'
) allowEwaste 
	on allowEwaste.Code = disp.Code

where 1=1
	and a.Tag_ID = @Tag_ID
	and a.Is_Active = 1

/*select 
	'- Asset with Tag ID: ' + @Tag_ID + ' does not exist.' as Error  
where 0 = (select count(*) total from Asset a where a.Tag_ID = @Tag_ID) 

union all

--6. Check to see if the tag is inactive
select top 1
	'- Asset with Tag ID: ' + @Tag_ID + ' is inactive.'
from Asset a
where a.Tag_ID = @Tag_ID
	and a.Is_Active = 0

union all

--7. Check to see if asset disposition is allowed to be checkin
select top 1
	'- Disposition on Asset is not allowed to be checkin: ' + disp.Name + '. Please investigate further.'  
from Asset a
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
where a.Tag_ID = @Tag_ID
	and disp.Allow_CheckIn = 0
	*/

GO
