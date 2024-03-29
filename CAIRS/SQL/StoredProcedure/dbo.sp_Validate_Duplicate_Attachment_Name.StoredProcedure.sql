USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Duplicate_Attachment_Name]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Duplicate_Attachment_Name]
		@Asset_ID as varchar(100),
		@Attachement_ID as varchar(100),
		@Attachment_Name as varchar(100),
		@Attachment_Type as Varchar(100)
AS

	SELECT
		'Duplicate Attachment Name and File Type'
    FROM Asset_Attachment a
    INNER JOIN CT_File_Type ft
	    ON ft.ID = a.File_Type_ID
    WHERE 1=1
        AND a.Asset_ID = @Asset_ID
	    AND a.Name = @Attachment_Name
	    AND ft.Name = @Attachment_Type
		AND a.ID <> CASE WHEN @Attachement_ID is null THEN -1 ELSE @Attachement_ID END



GO
