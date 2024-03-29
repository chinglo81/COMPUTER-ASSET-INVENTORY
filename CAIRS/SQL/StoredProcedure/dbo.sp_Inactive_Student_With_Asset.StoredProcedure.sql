USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Inactive_Student_With_Asset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Inactive_Student_With_Asset]
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
	mas.Asset_Site_Code,
	mas.Asset_Site_Desc,
	mas.Student_ID,
	Datawarehouse.dbo.getStudentNameById(mas.Student_ID) as Student_Name,
	s.Grade,
	s.LeaveDate,
	s.LeaveCode,
	leave.CODEDESC as LeaveDesc,
	mas.Tag_ID,
	mas.Serial_Number,
	mas.Asset_Base_Type_Desc,
	mas.Asset_Type_Desc,
	mas.Asset_Disposition_Desc,
	mas.Date_Check_In,
	mas.Date_Check_Out,
	dbo.FormatDateTime(getdate(),'MM/DD/YYYY') as Date_Today

from v_Asset_Master_List mas
inner join Datawarehouse.dbo.Student s
	on s.StudentId = mas.Student_ID
	and s.StudentStatus is not null
left join Datawarehouse.dbo.GlobalCodes leave
	on leave.CODE = s.LeaveCode
	and leave.TABLETYPE = 'LVE'

where mas.Asset_Disposition_ID = 1 --Assigned
	and mas.Asset_Site_Code in (select * from @Tbl_School_List)
	and	s.Grade in (select * from @Tbl_Grade_List)

order by 
	mas.Asset_Site_Desc,
	Student_Name

GO
