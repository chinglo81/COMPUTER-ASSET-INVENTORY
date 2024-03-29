USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Asset_Student_Fee]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[v_Asset_Student_Fee]
AS

select 
	amas.Tag_ID,
	amas.Serial_Number,
	amas.Asset_Site_ID,
	amas.Asset_Site_Desc,
	amas.Asset_Site_Code,
	amas.Asset_Base_Type_Desc,
	amas.Asset_Type_Desc,
	Datawarehouse.dbo.getStudentNameById(sfee.Student_ID) as Student_Name,
	sfee.*,
	'$' + cast(cast(sfee.Owed_Amount as decimal(10,2)) as varchar(100)) as Owed_Amount_Formatted,
	Datawarehouse.dbo.getEmployeeNameById(sfee.Added_By_Emp_ID) as Added_By_Emp_Name,
	Datawarehouse.dbo.getEmployeeNameById(sfee.Modified_By_Emp_ID) as Modified_By_Emp_Name,
	dbo.FormatDateTime(sfee.Date_Added,'MM/DD/YYYY') as Date_Added_Formatted,
	dbo.FormatDateTime(sfee.Date_Modified,'MM/DD/YYYY') as Date_Modified_Formatted,
	dbo.FormatDateTime(sfee.Date_Processed_Fee,'MM/DD/YYYY') as Date_Processed_Fee_Formatted,
	dbo.FormatDateTime(sfee.Date_Processed_School_Msg,'MM/DD/YYYY') as Date_Processed_School_Msg_Formatted,
	case when sfee.Student_Device_Coverage_ID is not null then 'Yes' else 'No' end as Has_Insurance_Coverage,
	case when sfee.Date_Processed_Fee is not null then 'Yes' else 'No' end as Is_Processed_Fee_To_MOSIS,
	case when sfee.Date_Processed_School_Msg is not null then 'Yes' else 'No' end as Is_Processed_School_Messenger,
	ft_map.Fee_Type_Desc
	
from Asset_Student_Fee sfee with(nolock)
inner join v_Asset_Master_List amas with(nolock)
	on amas.Asset_ID = sfee.Asset_ID
left join CT_Fee_Type_Mapping ft_map with (nolock)
	on ft_map.Asset_Disposition_ID = sfee.Asset_Disposition_ID
	and ft_map.Asset_Base_Type_ID = sfee.Asset_Base_Type_ID
left join mcs.dbo.FeeCodes fc
	on fc.FeeCode = ft_map.Fee_Code










GO
