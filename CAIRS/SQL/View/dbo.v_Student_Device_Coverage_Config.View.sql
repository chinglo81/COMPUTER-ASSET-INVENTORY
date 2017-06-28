USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Student_Device_Coverage_Config]    Script Date: 6/28/2017 11:00:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[v_Student_Device_Coverage_Config]
AS

select 
	ft.Name as Device_Fee_Type_Name,
	config.*,
	fname.Name as File_Name,
	config.File_Path + fname.Name as File_Path_Name

from Student_Device_Coverage_Config config
inner join CT_Device_Fee_Type ft
	on ft.ID = config.Device_Fee_Type_ID
cross join Business_Rule fname
where fname.Code = 'Stu_Device_Coverage_File_Name'







GO
