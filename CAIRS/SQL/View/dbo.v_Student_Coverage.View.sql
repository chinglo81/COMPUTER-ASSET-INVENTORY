USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Student_Coverage]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_Student_Coverage]
AS

select
	c.Student_ID,
	dt.Name as Coverage_Type, 
	c.School_Year,
	c.Is_Active
from Student_Device_Coverage c with(nolock)
inner join CT_Device_Fee_Type dt with(nolock)
	on dt.ID = c.Device_Fee_Type_ID
where c.Is_Active = 1




GO
