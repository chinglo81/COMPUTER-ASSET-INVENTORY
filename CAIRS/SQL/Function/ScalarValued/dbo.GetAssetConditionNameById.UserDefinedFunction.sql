USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAssetConditionNameById]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetAssetConditionNameById] (@Id int)
  
RETURNS varchar(100) 
AS  
BEGIN

DECLARE @name varchar(100)

SET @name =	(SELECT Name FROM CT_Asset_Condition WHERE ID = @Id	)

RETURN @name

END
GO
