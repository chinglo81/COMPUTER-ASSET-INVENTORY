USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_p_Student_One_ADP]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [dbo].[v_p_Student_One_ADP]
AS
/*
This view is used to create the school messenger file for students with 1 ADP usage for laptop
*/

select 
	f.Student_ID,
	case when stu.CorrespondenceLanguageCode = '01' then s.School_Messenger_Name_Spanish else s.School_Messenger_Name end as Asset_Site_Desc

from Asset_Student_Fee f with(nolock)
inner join Datawarehouse.dbo.Student stu with(nolock)
	on stu.StudentId = f.Student_ID
inner join Asset_Student_Transaction astu with(nolock)
	on astu.ID = f.Asset_Student_Transaction_ID 
inner join CT_Site s with(nolock)
	on s.ID = astu.Asset_Site_ID

where 1=1
	and stu.StudentStatus is null --Active student
	and f.Student_Device_Coverage_ID is not null --has coverage
	and f.Date_Processed_School_Msg is null --has not been processed
	and f.Asset_Disposition_ID = 1005 --Only broken 
	and f.Asset_Base_Type_ID = 1 --laptop only
	and f.Owed_Amount = 0 --amount owed is zero
	and f.Is_Active = 1

group by
	f.Student_ID,
	s.School_Messenger_Name,
	s.School_Messenger_Name_Spanish,
	case when stu.CorrespondenceLanguageCode = '01' then s.School_Messenger_Name_Spanish else s.School_Messenger_Name end






GO
