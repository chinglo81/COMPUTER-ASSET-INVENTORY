USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Student_Without_Laptop]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Student_Without_Laptop]
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

with student_with_checkout_assets as (
       select 
              mas.Asset_Disposition_Desc,
              ast.*
       from Asset_Student_Transaction ast with (nolock)
       inner join v_Asset_Master_List mas with (nolock)
              on mas.Asset_ID = ast.Asset_ID
       where 1=1
              and ast.Date_Check_In is null
              and mas.Asset_Disposition_Desc = 'Assigned'
              and mas.Asset_Base_Type_ID = 1 --Laptop
)

select 
       sch.SchoolNum,
       sch.ShortName as School_Name,
       stu.StudentID,
       stu.LastName,
       stu.FirstName,
	   stu.Grade,
	   stu.Teacher_CounselorName,
       stu.InstructionalSettingDesc
from Datawarehouse.dbo.Student stu with (nolock) 
inner join Datawarehouse.dbo.School sch 
       on stu.SasiSchoolNum = sch.SasiSchoolNum

where 1=1
	and stu.SasiSchoolNum in (select * from @Tbl_School_List)
	and stu.Grade in (select * from @Tbl_Grade_List)		
    and stu.SasiSchoolNum not in (
            '053', --Elliott Alternative Programs
            '045' --Elliott Continuation School
    )
    and stu.HS = 1 --only hs students
    and stu.studentstatus is null --Active students
    and stu.StudentId not in ( --exclude students who already have checkout laptops
            select a.Student_ID from student_with_checkout_assets a
    )
    and stu.InstructionalSettingCode not in (
                    '23',--G230
                    '84','87','88','90','98',--LTIS & MVA 
                    '85', --Gregori Tops
                    '86', --Johansen Tops
                    '71', --SDC SH
                    '' 
            )
    and stu.GradReqSetId not in ( 
                    --SDC LLH (Strand B) 
                    '101',
                    '108',
                    '116',
                    '124',
                    '132',
                    '140',
                    '148',
                    '156',
                    '164',
                    '172',
                    '257',
                    '307',
                    '458',
                    '807',
                    -----SDC-PH and SDC-MH (Strand A)
                    '53',
                    '107',
                    '115',
                    '123',
                    '131',
                    '139',
                    '147',
                    '155',
                    '163',
                    '171',
                    '256',
                    '306',
                    '457',
                    '806'
            )
       

order by 
       sch.Name,
       stu.LastName,
       stu.FirstName
GO
