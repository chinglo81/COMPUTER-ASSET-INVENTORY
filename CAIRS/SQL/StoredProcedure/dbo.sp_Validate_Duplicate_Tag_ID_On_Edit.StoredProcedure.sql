USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Duplicate_Tag_ID_On_Edit]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Duplicate_Tag_ID_On_Edit]
		@Asset_ID AS INT,
		@Tag_ID AS VARCHAR(100)
AS

	SELECT
		'Duplicate Tag ID: ' + a.Tag_ID
    FROM Asset a
	WHERE 1=1
		and a.Tag_ID = @Tag_ID
	    and a.id <> @Asset_ID


GO
