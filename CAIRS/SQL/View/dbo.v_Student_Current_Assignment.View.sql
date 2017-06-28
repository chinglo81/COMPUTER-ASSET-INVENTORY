USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Student_Current_Assignment]    Script Date: 6/28/2017 11:00:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[v_Student_Current_Assignment]
AS

select 
	a.*, 
	case when allow_check_in.Code IS NULL then 0 else 1 end as Disposition_Allow_CheckIn
from v_Asset_Student_Assginment a
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID

left join (
	select distinct
		d.Code
	from Business_Rule b with (nolock)
	inner join Business_Rule_Detail d with (nolock)
		on d.Business_Rule_ID = b.ID
	where b.Code = 'Disp_Allow_CheckIn'
		and b.Table_Name = 'CT_Asset_Disposition'
) allow_check_in
	on allow_check_in.Code = disp.Code

where 1=1
	--and (a.Student_ID = @Student_ID OR a.Serial_Number = @SerialNumber OR a.Tag_ID = @Tag_ID)
	and a.Date_Check_In is null
	and disp.Code = '1' --disposition must be assigned




GO
