USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[FormatDateTime]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--function to format date and time and day of week using simple format specifiers
--example: MCS.dbo.FormatDateTime(xyzdate,'mm/dd/yy')
CREATE FUNCTION [dbo].[FormatDateTime] 
( 
    @dt DATETIME, 
    @format VARCHAR(50) 
) 
RETURNS VARCHAR(64) 
AS 
BEGIN 
    DECLARE @dtVC VARCHAR(64) 
    SELECT @dtVC = CASE @format 
 
	WHEN 'MM/DD/YYYY HH:MM AM/PM' THEN
		CONVERT(CHAR(8), @dt, 1) + ' ' + LTRIM(RIGHT(CONVERT(VARCHAR(20), @dt, 22), 11)) 
  
    WHEN 'BOARDDATE' THEN 
		DATENAME(m, @dt) 
        + SPACE(1) + CAST(DAY(@dt) AS VARCHAR(2)) 
        + ',' + SPACE(1) + CAST(YEAR(@dt) AS CHAR(4)) 
 
    WHEN 'LONGDATE' THEN 
 
        DATENAME(dw, @dt) 
        + ',' + SPACE(1) + DATENAME(m, @dt) 
        + SPACE(1) + CAST(DAY(@dt) AS VARCHAR(2)) 
        + ',' + SPACE(1) + CAST(YEAR(@dt) AS CHAR(4)) 
 
    WHEN 'LONGDATEANDTIME' THEN 
 
        DATENAME(dw, @dt) 
        + ',' + SPACE(1) + DATENAME(m, @dt) 
        + SPACE(1) + CAST(DAY(@dt) AS VARCHAR(2)) 
        + ',' + SPACE(1) + CAST(YEAR(@dt) AS CHAR(4)) 
        + SPACE(1) + RIGHT(CONVERT(CHAR(20), 
        @dt - CONVERT(DATETIME, CONVERT(CHAR(8), 
        @dt, 112)), 22), 11) 
 
    WHEN 'SHORTDATE' THEN 
 
        LEFT(CONVERT(CHAR(19), @dt, 0), 11) 
 
    WHEN 'SHORTDATEANDTIME' THEN 
 
        REPLACE(REPLACE(CONVERT(CHAR(19), @dt, 0), 
            'AM', ' AM'), 'PM', ' PM') 
 
    WHEN 'UNIXTIMESTAMP' THEN 
 
        CAST(DATEDIFF(SECOND, '19700101', @dt) 
        AS VARCHAR(64)) 
 
    WHEN 'YYYYMMDD' THEN 
 
        CONVERT(CHAR(8), @dt, 112) 
 
    WHEN 'YYYY-MM-DD' THEN 
 
        CONVERT(CHAR(10), @dt, 23) 
 
    WHEN 'YYMMDD' THEN 
 
        CONVERT(VARCHAR(8), @dt, 12) 
 
    WHEN 'YY-MM-DD' THEN 
 
        STUFF(STUFF(CONVERT(VARCHAR(8), @dt, 12), 
        5, 0, '-'), 3, 0, '-') 
 
    WHEN 'MMDDYY' THEN 
 
        REPLACE(CONVERT(CHAR(8), @dt, 10), '-', SPACE(0)) 
        
    WHEN 'MMDDYYYY' THEN --used for ELC submission
 
        REPLACE(CONVERT(CHAR(10), @dt, 101), '/', SPACE(0)) 
 
    WHEN 'MM-DD-YY' THEN 
 
        CONVERT(CHAR(8), @dt, 10) 
 
    WHEN 'MM/DD/YY' THEN 
 
        CONVERT(CHAR(8), @dt, 1) 
 
    WHEN 'MM/DD/YYYY' THEN 
 
        CONVERT(CHAR(10), @dt, 101) 
        
    WHEN 'M/D/YYYY' THEN 
 
		CAST(MONTH(@dt) AS VARCHAR(2)) + '/' + CAST(DAY(@dt) AS VARCHAR(2)) + '/' + CAST(YEAR(@dt) AS VARCHAR(4))
	
	WHEN 'M/D/YY' THEN 
 
		CAST(MONTH(@dt) AS VARCHAR(2)) + '/' + CAST(DAY(@dt) AS VARCHAR(2)) + '/' + SUBSTRING(CAST(YEAR(@dt) as VARCHAR(4)),3,2) 
		
    WHEN 'DDMMYY' THEN 
 
        REPLACE(CONVERT(CHAR(8), @dt, 3), '/', SPACE(0)) 
 
    WHEN 'DD-MM-YY' THEN 
 
        REPLACE(CONVERT(CHAR(8), @dt, 3), '/', '-') 
 
    WHEN 'DD/MM/YY' THEN 
 
        CONVERT(CHAR(8), @dt, 3) 
 
    WHEN 'DD/MM/YYYY' THEN 
 
        CONVERT(CHAR(10), @dt, 103) 
        
    WHEN 'MM-DD-YYYY' THEN 
 
		RIGHT('00' + CAST(MONTH(@dt) AS VARCHAR(2)),2) + '-' + RIGHT('00' + CAST(DAY(@dt) AS VARCHAR(2)),2) + '-' + CAST(YEAR(@dt) AS VARCHAR(4))
	
    WHEN 'MM/YYYY' THEN 
 
        CONVERT(Varchar(2),DATEPART(M,@dt)) +'/' + Convert(Varchar(4),DATEPART(YEAR,@dt))
        
    WHEN 'DD/MM' THEN 
 
        CONVERT(Varchar(2),DATEPART(D,@dt)) +'/' + Convert(Varchar(2),DATEPART(M,@dt))
	WHEN 'HH:MM AM/PM' THEN
		LTRIM(RIGHT(CONVERT(VARCHAR(20), @dt, 22), 11)) 
        
     WHEN 'HH:MM:SS 24' THEN 
 
        CONVERT(CHAR(8), @dt, 8) 
 
    WHEN 'HH:MM 24' THEN 
 
        LEFT(CONVERT(VARCHAR(8), @dt, 8), 5) 
 
    WHEN 'HH:MM:SS 12' THEN 
 
        LTRIM(RIGHT(CONVERT(VARCHAR(20), @dt, 22), 11)) 
 
    WHEN 'HH:MM 12' THEN 
 
        LTRIM(SUBSTRING(CONVERT( 
        VARCHAR(20), @dt, 22), 10, 5) 
        + RIGHT(CONVERT(VARCHAR(20), @dt, 22), 3)) 

    WHEN 'DOW' THEN 
 
	CASE Datepart(dw,@dt)
	when 1 then 'Sunday'
	when 2 then 'Monday'
	when 3 then 'Tuesday'
	when 4 then 'Wednesday'
	when 5 then 'Thursday'
	when 6 then 'Friday'
	when 7 then 'Saturday'
	ELSE 'Unknown'
	END

    WHEN 'MONTH' THEN 
    DATENAME(m, @dt)
	 
    ELSE 
 
        'Invalid format specified' 
 
    END 
    RETURN @dtVC 
END 





GO
