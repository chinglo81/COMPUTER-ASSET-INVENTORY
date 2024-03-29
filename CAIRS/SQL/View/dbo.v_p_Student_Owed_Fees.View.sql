USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_p_Student_Owed_Fees]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















CREATE VIEW [dbo].[v_p_Student_Owed_Fees]
AS
/*
This view is used to create the school messenger file for students with fees
*/

select 
	a.Student_ID,
	sum(cast(a.Owed_Amount as decimal(10,2))) Owed_Amount,
	case when stu.CorrespondenceLanguageCode = '01' then s.School_Messenger_Name_Spanish else s.School_Messenger_Name end as Asset_Site_Desc

from Asset_Student_Fee a with(nolock)
inner join Datawarehouse.dbo.Student stu with(nolock)
	on stu.StudentId = a.Student_ID
inner join Asset_Student_Transaction astu with (nolock)
	on astu.ID = a.Asset_Student_Transaction_ID 
inner join CT_Site s with (nolock)
	on s.ID = astu.Asset_Site_ID

where 1=1
	and a.Date_Processed_School_Msg is null
	and a.Is_Active = 1

group by
	a.Student_ID,
	case when stu.CorrespondenceLanguageCode = '01' then s.School_Messenger_Name_Spanish else s.School_Messenger_Name end

having sum(a.Owed_Amount) > 0









GO
