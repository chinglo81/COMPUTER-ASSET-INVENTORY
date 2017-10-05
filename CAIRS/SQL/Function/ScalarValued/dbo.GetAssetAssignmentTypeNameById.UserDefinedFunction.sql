USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAssetAssignmentTypeNameById]    Script Date: 2/3/2017 10:36:26 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetAssetAssignmentTypeNameById] (@Id int)
  
RETURNS varchar(100) 
AS  
BEGIN

DECLARE @name varchar(100)

SET @name =	(SELECT Name FROM CT_Asset_Assignment_Type WHERE ID = @Id	)

RETURN @name

END
GO
