USE [Asset_Tracking]
GO
/****** Object:  UserDefinedFunction [dbo].[CreateHTMLTable]    Script Date: 10/5/2017 11:34:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CreateHTMLTable](@SelectForXmlRawElementsXsinil XML)
RETURNS XML
AS
BEGIN

DECLARE @ReturnXML XML
SET @ReturnXML = (
					SELECT  
					@SelectForXmlRawElementsXsinil.query('let $first:=/row[1]
								return 
								<tr> 
								{
								for $th in $first/*
								return <th>{local-name($th)}</th>
								}
								</tr>') AS thead
					,@SelectForXmlRawElementsXsinil.query('for $tr in /row
								 return 
								 <tr>
								 {
								 for $td in $tr/*
								 return <td>{string($td)}</td>
								 }
								 </tr>') AS tbody
					FOR XML PATH('table'),TYPE
				)

SET @ReturnXML = CASE WHEN cast(@ReturnXML as varchar(MAX)) = '<table/>' then '' else @ReturnXML END

RETURN
(
	SELECT  @ReturnXML
);
END

GO
