USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Asset_Statistic]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Ching Lo>
-- Create date: <2017-10-01>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Asset_Statistic]
		@School_List as varchar(MAX), 
		@Disposition_List as VARCHAR(MAX),
		@Is_Leased as varchar(3)
AS

--Temp table that holds the list of schools process
DECLARE @Tbl_School_List AS TABLE(
	School_Number VARCHAR(3)
)
--Temp table that holds the list of grades process
DECLARE @Tbl_Disposition AS TABLE(
	Code VARCHAR(100)
)

--Insert paramter into temp tables
INSERT INTO @Tbl_School_List
SELECT * FROM dbo.CSVToTable(@School_List,',')

INSERT INTO @Tbl_Disposition
SELECT * FROM dbo.CSVToTable(@Disposition_List,',')
;

select
	s.Short_Name as Asset_Site_Desc,
	disp.Name as Asset_Disposition_Desc,
	bt.Name as Asset_Base_Type_Desc,
	case when a.Is_Leased = 1 then 'Yes' else 'No' end as Is_Leased,
	count(*) as Total,
	dbo.FormatDateTime(getdate(),'MM/DD/YYYY') as Date_Today

from Asset a
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_disposition_ID
inner join CT_Asset_Type t
	on t.ID = a.Asset_Type_ID
inner join CT_Asset_Base_Type bt
	on bt.id = t.Asset_Base_Type_ID
inner join Asset_Site_Mapping sm
	on sm.Asset_ID = a.ID
inner join CT_Site s
	on s.ID = sm.Site_ID

where 1=1
	and a.Is_Active = 1
	and (a.Asset_Disposition_ID in (select * from @Tbl_Disposition) or @Disposition_List = 'all')
	and (s.Code in (select * from @Tbl_School_List) or @School_List = 'all')
	and (a.Is_Leased = case when @Is_Leased = 'yes' then 1 else 0 end or @Is_Leased = 'all')

group by
	s.Short_Name,
	a.Is_Leased,
	bt.Name,
	disp.Name

order by
	s.Short_Name,
	a.Is_Leased,
	disp.name,
	bt.Name



GO
