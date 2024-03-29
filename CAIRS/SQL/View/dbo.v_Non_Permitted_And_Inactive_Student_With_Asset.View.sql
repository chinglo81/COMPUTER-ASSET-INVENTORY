USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Non_Permitted_And_Inactive_Student_With_Asset]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[v_Non_Permitted_And_Inactive_Student_With_Asset]
AS



select 
	astu.id as Asset_Student_Transaction_ID,
	amas.Asset_ID,
	amas.Asset_Base_Type_Desc,
	amas.Asset_Type_Desc,
	amas.Tag_ID,
	amas.Serial_Number,
	amas.Asset_Disposition_ID,
	amas.Asset_Disposition_Desc,
	astu.Date_Check_Out,
	astu.Student_ID,
	s.StudentStatus,
	case when s.StudentStatus is not null then 'Inactive Student' else non_permitted.Non_Permit_Reason end as Reason
from Asset_Student_Transaction astu
inner join v_Asset_Master_List amas
	on astu.Asset_ID = amas.Asset_ID
inner join Datawarehouse.dbo.Student s
	on s.StudentId = astu.Student_ID
left join v_Non_Permitted_Student non_permitted
	on non_permitted.StudentId = astu.Student_ID

where 1=1 
	and astu.Date_Check_In is null
	and amas.Asset_Disposition_ID = 1 --Must be assigned
	and (
		s.StudentStatus is not null --inactive students
		or
		non_permitted.StudentId is not null
	)








GO
