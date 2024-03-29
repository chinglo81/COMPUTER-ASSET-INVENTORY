USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Non_Permitted_Student_With_Asset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Non_Permitted_Student_With_Asset]
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


select 
	stu.StudentStatus,
	asset.Student_ID,
	Datawarehouse.dbo.getStudentNameById(stu.StudentId) as Student_Name,
	stu.Grade,
	stu.InstructionalSettingDesc,
	stu.GradReqSetId,
	----------
	case 
			when stu.InstructionalSettingCode in ('23') 
				then 'Instr Setting: G230; '
			when stu.InstructionalSettingCode in ('84','87','88','90','98') 
				then 'Instr Setting: Independent Study; '
			when stu.InstructionalSettingCode in ('85') 
				then 'Instr Setting: TOPS Gregori; '
			when stu.InstructionalSettingCode in ('86') 
				then 'Instr Setting: TOPS Johansen; '
			when stu.InstructionalSettingCode in ('71') 
				then 'Instr Setting: SDC SH; '
			else ''

		end 
	+	case
			when stu.GradReqSetId in ( 
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
				'807'
			) then 'Grad Plan: Strand B; '
			when stu.GradReqSetId in ( 
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
			) then 'Grad Plan: Strand A; '
			
			
			else ''
		end as Reason,

	----------
	c.Date_Paid as Coverage_Paid_Date,
	sch.ShortName as Student_School,
	asset.Asset_Site_Desc,
	asset.Asset_Base_Type_Desc,
	asset.Asset_Type_Desc,
	asset.Tag_ID,
	asset.Serial_Number,
	asset.Date_Check_Out,
	dbo.FormatDateTime(getdate(),'MM/DD/YYYY') as Date_Today

from Datawarehouse.dbo.Student stu with (nolock)
inner join Student_Device_Coverage c  with (nolock)
	on c.Student_ID = stu.StudentId
inner join Datawarehouse.dbo.School sch  with (nolock)
	on stu.SasiSchoolNum = sch.SchoolNum
inner join v_Asset_Master_List asset  with (nolock)
	on asset.Student_ID = stu.StudentId
	and asset.Asset_Disposition_ID = 1 --Assigned

where 1=1
	and stu.StudentStatus is null
	and (
		stu.InstructionalSettingCode in (
			'23',--G230
			'84','87','88','90','98',--LTIS & MVA 
			'85', --Gregori Tops
			'86', --Johansen Tops
			'71', --SDC SH
			'' 
		)
		OR stu.GradReqSetId in ( 
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
	)

	and asset.Asset_Site_Code in (select * from @Tbl_School_List)
	and	stu.Grade in (select * from @Tbl_Grade_List)

order by 
	asset.Asset_Site_Desc,
	Student_Name

GO
