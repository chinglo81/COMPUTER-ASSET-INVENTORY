USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Import_Record_99_End]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Import_Record_99_End] AS

--Archive Data	
insert into Import_Record_History
select * from Import_Record

--Intilize Record
Delete from Import_Record







GO
