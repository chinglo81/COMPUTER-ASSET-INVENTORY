USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[PadLeft]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PadLeft]
(
    @string VARCHAR(MAX), -- Initial string
    @length INT,          -- Size of final string
    @pad CHAR             -- Pad character
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN REPLICATE(@pad, @length - LEN(@string)) + @string;
END

GO
