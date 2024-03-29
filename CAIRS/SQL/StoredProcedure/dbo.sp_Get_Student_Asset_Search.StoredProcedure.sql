USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_Student_Asset_Search]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Get_Student_Asset_Search]
	@StudentIDs as VARCHAR(MAX),
	@Disposition_List as VARCHAR(MAX),
	@Asset_Site as VARCHAR(30),
	@Asset_Base_Type as VARCHAR(30),
	@Asset_Type as VARCHAR(30), 
	@Is_Excel_Export as VARCHAR(1)
AS

--Temp table that holds the list of student ids
DECLARE @Tbl_Student_List AS TABLE(
	Student_ID VARCHAR(20)
)
--Temp table that holds the list disposition
DECLARE @Tbl_Disposition AS TABLE(
	Disposition_ID VARCHAR(100)
)

--Insert paramter into temp tables
INSERT INTO @Tbl_Student_List
SELECT * FROM dbo.CSVToTable(@StudentIDs,',')

INSERT INTO @Tbl_Disposition
SELECT * FROM dbo.CSVToTable(@Disposition_List,',')
;


IF @Is_Excel_Export = '1'
	BEGIN
		SELECT
			v.School_Year as 'Year',
			v.Student_ID as 'Student ID',
			v.Student_Name as 'Student',
			v.Student_School_Name as 'Site',
			v.Tag_ID as 'Tag ID',
			v.Asset_Base_Type_Desc as 'Base Type',
			v.Asset_Type_Desc as 'Asset Type',
			v.Date_Check_Out_Formatted as 'Checkout',
			v.Date_Check_In_Formatted as 'Check-in',
			v.Check_In_Asset_Disposition_Desc as 'Check-in Disp'
		FROM v_Student_Asset_Search v
		WHERE 1=1
			and (v.Student_ID in (Select * from @Tbl_Student_List) OR len(ltrim(rtrim(@StudentIDs))) = 0) 
			and (v.Check_In_Disposition_ID in (Select * from @Tbl_Disposition) OR len(ltrim(rtrim(@Disposition_List))) = 0)
			and (v.Asset_Site_ID = @Asset_Site OR len(ltrim(rtrim(@Asset_Site))) = 0 OR @Asset_Site like '-%') 
			and (v.Asset_Base_Type_ID = @Asset_Base_Type OR len(ltrim(rtrim(@Asset_Base_Type))) = 0 OR @Asset_Base_Type like '-%') 
			and (v.Asset_Type_ID = @Asset_Type OR len(ltrim(rtrim(@Asset_Type))) = 0 OR @Asset_Type like '-%') 
			
	END
ELSE
	BEGIN
		select 
			v.*
		from v_Student_Asset_Search v
		WHERE 1=1
			and (v.Student_ID in (Select * from @Tbl_Student_List) OR len(ltrim(rtrim(@StudentIDs))) = 0) 
			and (v.Check_In_Disposition_ID in (Select * from @Tbl_Disposition) OR len(ltrim(rtrim(@Disposition_List))) = 0)
			and (v.Asset_Site_ID = @Asset_Site OR len(ltrim(rtrim(@Asset_Site))) = 0 OR @Asset_Site like '-%') 
			and (v.Asset_Base_Type_ID = @Asset_Base_Type OR len(ltrim(rtrim(@Asset_Base_Type))) = 0 OR @Asset_Base_Type like '-%') 
			and (v.Asset_Type_ID = @Asset_Type OR len(ltrim(rtrim(@Asset_Type))) = 0 OR @Asset_Type like '-%') 
	END


GO
