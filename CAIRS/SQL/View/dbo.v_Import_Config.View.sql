USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Import_Config]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[v_Import_Config]
AS

select 
	ft.Name as Device_Fee_Type_Name,
	config.*,
	fname.Name as File_Name,
	config.File_Path + fname.Name as File_Path_Name

from Import_Config config with(nolock)
inner join CT_Device_Fee_Type ft with(nolock)
	on ft.ID = config.Device_Fee_Type_ID
cross join Business_Rule fname with(nolock)
where fname.Code = 'Import_Process_File_Name'










GO
