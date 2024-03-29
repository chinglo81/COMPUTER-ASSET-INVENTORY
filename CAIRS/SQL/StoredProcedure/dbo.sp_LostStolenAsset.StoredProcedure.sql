USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_LostStolenAsset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Josh Pohl
-- Create date: 10/02/2017
-- Update date:	10/04/2017
-- Update by:	Josh Pohl
-- Description:	Stored Procedure for LostStolenAsset Report
-- =============================================
CREATE PROCEDURE [dbo].[sp_LostStolenAsset]
	-- Add the parameters for the stored procedure here
		@School_List AS VARCHAR(MAX), 
		@Grade_List AS VARCHAR(MAX),
		@From_Date AS DATE,
		@To_Date AS DATE,
		@Asset_Base_Type_List AS VARCHAR(MAX),
		@Asset_Type_List AS VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
--Temp table that holds the list of schools process
DECLARE @Tbl_School_List AS TABLE(
	School_Number VARCHAR(3)
)
-- Temp table that holds the list of grades process
DECLARE @Tbl_Grade_List AS TABLE(
	Grade VARCHAR(2)
)
-- Temp table that holds the list of asset types process
DECLARE @Tbl_Asset_Base_Type_List AS TABLE(
	Asset_Base_Type INT
)
-- Temp table that holds the list of asset types process
DECLARE @Tbl_Asset_Type_List AS TABLE(
	Asset_Type INT
)
-- Temp table that holds the list of dispositions process
DECLARE @Tbl_Disposition_List AS TABLE(
	Disposition INT
)

-- Insert paramters into temp tables
INSERT INTO @Tbl_School_List
SELECT * FROM dbo.CSVToTable(@School_List, ',')

INSERT INTO @Tbl_Grade_List
SELECT * FROM dbo.CSVToTable(@Grade_List, ',')

INSERT INTO @Tbl_Asset_Base_Type_List
SELECT * FROM CSVToTable(@Asset_Base_Type_List, ',')

INSERT INTO @Tbl_Asset_Type_List
SELECT * FROM CSVToTable(@Asset_Type_List, ',')

INSERT INTO @Tbl_Disposition_List
SELECT ID FROM Asset_Tracking.dbo.CT_Asset_Disposition WHERE Code IN ('2','4')  -- Lost/Stolen


SELECT 
	stu.StudentStatus,
	assign.Student_ID,
	Datawarehouse.dbo.getStudentNameById(stu.StudentId) AS Student_Name,
	stu.Grade,
	stu.InstructionalSettingDesc,
	stu.GradReqSetId,
	sch.ShortName AS Student_School,
	assign.Asset_Site_Desc,
	assign.Asset_Base_Type_Desc,
	assign.Asset_Type_Desc,
	assign.Tag_ID,
	assign.Serial_Number,
	assign.Date_Check_In_Formatted,
	assign.Time_Check_in_Formatted,
	assign.Asset_Disposition_Desc,
	assign.Check_In_Disposition_Desc,
	assign.Fine_Amount

FROM Datawarehouse.dbo.Student stu with (nolock)
INNER JOIN Datawarehouse.dbo.School sch  with (nolock)
	ON stu.SasiSchoolNum = sch.SchoolNum
INNER JOIN v_Asset_Student_Assignment assign  with (nolock)
	ON assign.Student_ID = stu.StudentId

WHERE 1=1
	AND assign.Asset_Site_Code IN (SELECT * FROM @Tbl_School_List)
	AND	stu.Grade IN (SELECT * FROM @Tbl_Grade_List)
	AND Date_Check_In BETWEEN @From_Date AND @To_Date
	AND Asset_Base_Type_ID IN (SELECT * FROM @Tbl_Asset_Base_Type_List)
	AND Asset_Type_ID IN (SELECT * FROM @Tbl_Asset_Type_List)
	AND assign.Check_In_Disposition_ID IN (SELECT * FROM @Tbl_Disposition_List)

ORDER BY 
	assign.Asset_Site_Desc,
	Student_Name,
	Date_Check_In desc

END

GO
