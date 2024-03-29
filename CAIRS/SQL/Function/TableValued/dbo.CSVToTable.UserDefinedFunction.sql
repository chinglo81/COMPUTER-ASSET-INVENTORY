USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[CSVToTable]    Script Date: 10/5/2017 11:35:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CSVToTable] ( @StringInput VARCHAR(MAX), @Delimiter varchar(1))
RETURNS @OutputTable TABLE ( [String] VARCHAR(100) )
AS
BEGIN

    DECLARE @String    VARCHAR(100)

    WHILE LEN(@StringInput) > 0
    BEGIN
        SET @String      = LEFT(@StringInput, 
                                ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringInput) - 1, -1),
                                LEN(@StringInput)))
        SET @StringInput = SUBSTRING(@StringInput,
                                     ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringInput), 0),
                                     LEN(@StringInput)) + 1, LEN(@StringInput))

        INSERT INTO @OutputTable ( [String] )
        VALUES ( @String )
    END

    RETURN
END


GO
