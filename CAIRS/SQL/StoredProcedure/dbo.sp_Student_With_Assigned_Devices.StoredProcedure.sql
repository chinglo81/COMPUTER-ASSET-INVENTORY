USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Student_With_Assigned_Devices]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Student_With_Assigned_Devices]
		@School_List as varchar(MAX), 
		@Grade_List as VARCHAR(MAX),
		@Active as VARCHAR(10)
AS

--Temp table that holds the list of schools process
DECLARE @Tbl_School_List AS TABLE(
	School_Number VARCHAR(3)
)
--Temp table that holds the list of grades process
DECLARE @Tbl_Grade_List AS TABLE(
	Grade VARCHAR(2)
)

--Temp table that holds the list of status
DECLARE @Tbl_Student_Status as TABLE(
	Student_Status VARCHAR(1)
)

--Insert paramter into temp tables
INSERT INTO @Tbl_School_List
SELECT * FROM dbo.CSVToTable(@School_List,',')

INSERT INTO @Tbl_Grade_List
SELECT * FROM dbo.CSVToTable(@Grade_List,',')
;

INSERT INTO @Tbl_Student_Status
SELECT * FROM dbo.CSVToTable(@Active,',')
;

select 
	mas.Asset_ID,
	mas.Asset_Site_Desc,
	mas.Asset_Base_Type_Desc,
	mas.Asset_Type_Desc,
	mas.Tag_ID,
	mas.Serial_Number,
	mas.Student_ID,
	mas.Student_Assigned_To,
	stu.Grade,
	mas.Date_Check_Out, 
	case when coverage.Date_Paid is not null then 'Yes (Paid: ' + dbo.FormatDateTime(coverage.Date_Paid,'MM/DD/YYYY') + ')' else 'No' end as Has_Insurance,
	case when stu.StudentStatus is null then 'Active' else 'Inactive' end as Student_Status,
	dbo.FormatDateTime(getdate(),'MM/DD/YYYY') as Date_Today

from v_Asset_Master_List mas with (nolock)
inner join Datawarehouse.dbo.Student stu
	on stu.StudentID = mas.Student_ID
left join Student_Device_Coverage coverage with (nolock)
	on coverage.Student_ID = mas.Student_ID
	and coverage.School_Year = mcs.dbo.GetSchoolCCYY(getdate())
	and coverage.Is_Active = 1
	and mas.Asset_Base_Type_ID = 1 --coverage only for laptops

where 1=1
	and case when stu.StudentStatus is null then '1' else '0' end in (select * from @Tbl_Student_Status)
	and mas.Asset_Disposition_ID = 1 --Only assigned devices
	and mas.Asset_Site_Code in (
		select * from @Tbl_School_List
	)
	and stu.Grade in (
		select * from @Tbl_Grade_List
	)

order by 
	mas.Asset_Site_Desc,
	mas.Student_Assigned_To,
	mas.Asset_Base_Type_Desc


GO
