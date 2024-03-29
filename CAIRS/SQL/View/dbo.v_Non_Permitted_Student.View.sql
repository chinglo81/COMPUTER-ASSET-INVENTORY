USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Non_Permitted_Student]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[v_Non_Permitted_Student]
AS

select
	stu.*,
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
			) then 'Grad Plan: Strand B'
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
			) then 'Grad Plan: Strand A'
			
			
			else ''
		end as Non_Permit_Reason
from Datawarehouse.dbo.Student stu with (nolock)
where 1=1
	and stu.StudentStatus is null --active student
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








GO
