USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Student_With_Site_Mismatch_Asset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Student_With_Site_Mismatch_Asset]
		@School_List as varchar(MAX), 
		@Grade_List as VARCHAR(MAX)
AS

--Temp table that holds the list of schools process
DECLARE @Tbl_School_List AS TABLE(
	School_Number VARCHAR(3)
)
--Temp table that holds the list of grades process
DECLARE @Tbl_Grade_List AS TABLE(
	Grade VARCHAR(2)
)

--Insert paramter into temp tables
INSERT INTO @Tbl_School_List
SELECT * FROM dbo.CSVToTable(@School_List,',')

INSERT INTO @Tbl_Grade_List
SELECT * FROM dbo.CSVToTable(@Grade_List,',')
;


select 
	amas.Asset_Site_Code,
	amas.Asset_Site_Desc,
	stu_sch.SasiSchoolNum as Student_School_Number,
	stu_sch.ShortName as Student_Primary_School,
	amas.Student_ID,
	stu.Grade,
	Datawarehouse.dbo.getStudentNameById(amas.Student_ID) as Student_Name,
	amas.Asset_Base_Type_Desc,
	amas.Asset_Type_Desc,
	amas.Serial_Number,
	amas.Tag_ID,
	amas.Date_Check_Out,
	amas.Asset_Disposition_Desc,
	dbo.FormatDateTime(getdate(),'MM/DD/YYYY') as Date_Today

from v_Asset_Master_List amas
inner join Datawarehouse.dbo.Student stu
	on stu.StudentId = amas.Student_ID 
inner join Datawarehouse.dbo.School stu_sch
	on stu_sch.SasiSchoolNum = stu.SasiSchoolNum
left join CT_Site_Mapping sm
	on sm.CT_Site_ID = amas.Asset_Site_ID

where 1=1
	and amas.Asset_Disposition_ID = 1 --Assigned
	and stu.StudentStatus is null
	and amas.Asset_Site_Code <> stu.SasiSchoolNum
	and 1 = case when amas.Asset_Site_Code <> stu.SasiSchoolNum AND sm.Code = stu.SasiSchoolNum then 0 else 1 end --These students will appear in the non-permitted report
	and amas.Asset_Site_Code in (select * from @Tbl_School_List)
	and	stu.Grade in (select * from @Tbl_Grade_List)

group by
	amas.Asset_Site_Code,
	amas.Asset_Site_Desc,
	stu_sch.SasiSchoolNum,
	stu_sch.ShortName,
	amas.Student_ID,
	stu.Grade,
	amas.Student_Name,
	amas.Asset_Base_Type_Desc,
	amas.Asset_Type_Desc,
	amas.Serial_Number,
	amas.Tag_ID,
	amas.Date_Check_Out,
	amas.Asset_Disposition_Desc

order by 
	amas.Asset_Site_Desc,
	Student_Name


GO
