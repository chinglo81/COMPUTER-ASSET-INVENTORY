USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_Student_Device]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Get_Student_Device]
		@Student_ID AS VARCHAR(20)
AS

with owe_fees_by_transaction as (
	select 
		MAX(f.id) as Most_Recent_Fee_ID,
		f.Asset_Student_Transaction_ID,
		sum(f.Owed_Amount) as Total_Owed
	from v_Asset_Student_Fee f with (nolock)
	where f.Student_ID = @Student_ID
	group by
		f.Asset_Student_Transaction_ID
),

has_attahment as (
	select 
		a.Asset_Student_Transaction_ID,
		count(*) as total_attachment
	from Asset_Attachment a with (nolock)
	where 
		a.Asset_Student_Transaction_ID is not null
	group by
		a.Asset_Student_Transaction_ID
)

select 
	s.Student_ID,
	s.Student_Name,
	s.School_Year,
	s.Date_Check_Out_Formatted,
	s.Date_Check_In_Formatted,
	s.Date_Check_Out,
	s.Date_Check_In,
	mas.Asset_ID,
	mas.Asset_Base_Type_Desc,
	mas.Asset_Type_Desc,
	mas.Asset_Base_Type_Desc + ' - ' + mas.Asset_Type_Desc as Asset_Base_And_Type_Desc,
	mas.Tag_ID,
	mas.Serial_Number,
	isnull(isnull(most_recent_fee.Asset_Disposition_Desc, s.Check_In_Asset_Disposition_Desc), mas.Asset_Disposition_Desc) as Disposition,
	s.Asset_Student_Transaction_ID,
	cast(isnull(fee.Total_Owed, 0) as decimal(10,2)) as Owed_Fee,
	isnull(a.total_attachment, 0) as Total_Attachment,
	case when most_recent_fee.Student_Device_Coverage_ID is null then 'No' else 'Yes' end as Student_Has_Coverage

from v_Student_Asset_Search s with (nolock)
inner join v_Asset_Master_List mas with (nolock)
	on mas.Asset_ID = s.Asset_ID
left join owe_fees_by_transaction fee with (nolock)
	on fee.Asset_Student_Transaction_ID = s.Asset_Student_Transaction_ID
left join Asset_Student_Fee most_recent_fee with (nolock)
	on most_recent_fee.ID = fee.Most_Recent_Fee_ID
	and most_recent_fee.Is_Active = 1
left join has_attahment a with (nolock)
	on a.Asset_Student_Transaction_ID = s.Asset_Student_Transaction_ID

where s.Student_ID =  @Student_ID

GO
