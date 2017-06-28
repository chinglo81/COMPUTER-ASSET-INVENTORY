USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Student_Coverage]    Script Date: 6/28/2017 11:00:30 AM ******/
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
from Student_Device_Coverage c
inner join CT_Device_Fee_Type dt
	on dt.ID = c.Device_Fee_Type_ID
where c.Is_Active = 1



GO
