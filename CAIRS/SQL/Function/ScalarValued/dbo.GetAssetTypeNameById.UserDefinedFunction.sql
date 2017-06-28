USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAssetTypeNameById]    Script Date: 6/28/2017 11:05:11 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetAssetTypeNameById] (@Id int)
  
RETURNS varchar(100) 
AS  
BEGIN

DECLARE @name varchar(100)

SET @name =	(SELECT Name FROM CT_Asset_Type WHERE ID = @Id	)

RETURN @name

END
GO
