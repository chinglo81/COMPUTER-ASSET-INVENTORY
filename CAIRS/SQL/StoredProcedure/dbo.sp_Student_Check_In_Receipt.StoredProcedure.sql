USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Student_Check_In_Receipt]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Student_Check_In_Receipt]
		@School_List as varchar(MAX) = null,
		@Grade_List as VARCHAR(MAX) = null,
		@Student_List as varchar(MAX) = null,
		@FromDate as date,
		@ToDate as date
AS

--Temp table that holds the list of schools process
DECLARE @Tbl_School_List AS TABLE(
	School_Number VARCHAR(3)
)

--Temp table that holds the list of grades process
DECLARE @Tbl_Grade_List AS TABLE(
	Grade VARCHAR(2)
)

--Temp table that holds the list of Student IDs
DECLARE @Tbl_Student_List AS TABLE(
	Student_ID VARCHAR(20)
)

--Insert paramter into temp tables
INSERT INTO @Tbl_School_List
SELECT * FROM dbo.CSVToTable(@School_List,',')

--Insert paramter into temp tables
INSERT INTO @Tbl_Grade_List
SELECT * FROM dbo.CSVToTable(@Grade_List,',')


--Insert paramter into temp tables
INSERT INTO @Tbl_Student_List
SELECT * FROM dbo.CSVToTable(@Student_List,',')
;

select 
	v.Student_ID,
	v.Student_Name,
	v.Student_Current_Grade,
	v.Student_School_Name,
	v.Asset_Site_Desc,
	v.Asset_Base_Type_Desc,
	v.Asset_Type_Desc,
	v.Serial_Number,
	v.Tag_ID,
	v.Date_Check_Out_Formatted,
	v.Check_Out_Asset_Condition_Desc,
	v.Date_Check_In_Formatted,
	v.Check_In_Disposition_Desc,
	v.Check_In_Asset_Condition_Desc,
	case when Check_In_Disposition_ID in (1004, 17) then 'Pending' else '$' + cast(v.Fine_Amount as varchar(100)) end as Fine_Amount,
	--Asset Info
	'Asset Site: ' + v.Asset_Site_Desc + '<br>' +
	'Type: ' + v.Asset_Base_Type_Desc + '<br>' +
	'Model: ' + v.Asset_Type_Desc + '<br>' +
	'Serial #: ' + v.Serial_Number + '<br>' +
	'Tag ID: ' + v.Tag_ID as Asset_Info_Display,
	--Checkout Info
	'Date: ' + v.Date_Check_Out_Formatted + '<br>' +
	'Time: ' + v.Time_Check_Out_Formatted + '<br>' +
	'Condition: ' + isnull(v.Check_Out_Asset_Condition_Desc, 'N/A') as Checkout_Display,
	--Check-in Info
	'Date: ' + v.Date_Check_In_Formatted + '<br>' +
	'Time: ' + v.Time_Check_in_Formatted + '<br>' +
	'Disposition: ' + v.Check_In_Disposition_Desc + '<br>' +
	'Condition: ' + isnull(v.Check_In_Asset_Condition_Desc, 'N/A') as Check_In_Display,
	case 
		when v.Asset_Base_Type_ID = 1 and v.Fine_Amount = 0 and v.Date_Check_In is not null and v.Asset_Disposition_ID in (2, 1005) --Stolen, Broken
			then 'Coverage Used.'
		else '' 
	end + isnull(v.Asset_Student_Fee_Comment, '') as Comment


from v_Asset_Student_Assignment v

where 1=1
	and cast(v.Date_Check_In as date) between @FromDate and @ToDate 
	and (
		v.Asset_Site_Code in (
			select * from @Tbl_School_List
		)
		or 
		@School_List is null
		or
		@School_List = ''
		or
		@School_List = 'all'
	)
	and (
		v.Student_Current_Grade in (
			select * from @Tbl_Grade_List
		)
		or 
		@Grade_List is null
		or
		@Grade_List = ''
		or 
		@Grade_List = 'all'
	)
	and 
	(	v.Student_ID in (
			select * from @Tbl_Student_List
		)
		or
		@Student_List is null
		or
		@Student_List = ''
	)	
	

order by 
	v.Asset_Site_Desc,
	v.Student_Name, 
	v.Date_Check_In desc

GO
