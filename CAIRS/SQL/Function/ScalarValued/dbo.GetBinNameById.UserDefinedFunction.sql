USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[GetBinNameById]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetBinNameById] (@Id int)
  
RETURNS varchar(100) 
AS  
BEGIN

DECLARE @name varchar(100)

SET @name =	(SELECT Description FROM Bin WHERE ID = @Id	)

RETURN @name

END
GO
