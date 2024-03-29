USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetTamperAttachmentForEmail]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--function to return description for a code
--example: MCS.dbo.GetCodeDesc(Code,Table)
CREATE FUNCTION [dbo].[GetTamperAttachmentForEmail] 
(
@Asset_Tamper_ID as int

)  
RETURNS Varchar(MAX)
AS 
BEGIN 
DECLARE @listStr VARCHAR(MAX)

SELECT  
	@listStr = COALESCE(@listStr + ';','') 
		+ CASE 
			WHEN @@SERVERNAME = 'RENO-SQLIS' THEN '\\MCS-APPS\C$\Project\CAIRS\Asset_Attachment\' 
			ELSE '\\MCS-APPS-TEST\C$\Project\CAIRS\Asset_Attachment\'
		  END
		+ cast(at.Asset_ID as VARCHAR(100)) + '\' + at.Name + '.' + ft.Name

from Asset_Attachment at
inner join CT_File_Type ft
	on ft.ID = at.File_Type_ID
where at.Asset_Tamper_ID = @Asset_Tamper_ID

RETURN ( 
	
	SELECT @listStr
)
END 

GO
