USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Import_Record_4_Update_Count]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Import_Record_4_Update_Count] 
(
	@DateTime AS DateTime
)

AS

DECLARE @Tbl_Counts as TABLE(
	Import_Config_ID INT,
	Last_Import_Count_Total INT,
	Last_Import_Count_Error INT,
	Last_Import_Count_Success INT,
	Last_Import_Count_Not_Processed INT
)

--Insert into temp table
INSERT INTO @Tbl_Counts
select 
	config.ID,
	count(*) as Last_Import_Count_Total,
	sum(case when import.Is_Processed = 1 and import.Is_Imported = 0 then 1 else 0 end) as Last_Import_Count_Error,
	sum(case when import.Is_Processed = 1 and import.Is_Imported = 1 then 1 else 0 end) as Last_Import_Count_Sucess,
	sum(case when import.Is_Processed = 0 then 1 else 0 end) as Last_Import_Count_Not_Processed

from Import_Record import
inner join Import_Config config
	on config.ID = import.Import_Config_ID
	
group by 
	config.ID,
	config.Last_Import_Status


--Update Counts
UPDATE Import_Config 
	set 
		Last_Import_Count_Error = r.Last_Import_Count_Error,
		Last_Import_Count_Not_Processed = r.Last_Import_Count_Not_Processed,
		Last_Import_Count_Success = r.Last_Import_Count_Success,
		Last_Import_Count_Total = r.Last_Import_Count_Total

from @Tbl_Counts r
inner join Import_Config c
	on c.ID = r.Import_Config_ID


--Update Date for all records
Update Import_Config
	Set Date_Last_Import = @DateTime
	



GO
