USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Student_CheckIn]    Script Date: 10/5/2017 11:32:27 AM ******/
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

--Check to se if disposition allows for check-in
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

GO
