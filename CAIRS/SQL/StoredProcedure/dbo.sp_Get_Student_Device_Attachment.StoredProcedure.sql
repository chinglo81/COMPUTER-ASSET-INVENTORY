USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_Student_Device_Attachment]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Get_Student_Device_Attachment]
		@Asset_Student_Transaction_ID AS INT
AS

select 
	* 

from v_Asset_Tab_Attachments v

where v.Asset_Student_Transaction_ID =  @Asset_Student_Transaction_ID

GO
