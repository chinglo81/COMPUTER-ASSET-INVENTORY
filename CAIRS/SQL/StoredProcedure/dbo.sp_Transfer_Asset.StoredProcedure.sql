USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Transfer_Asset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_Transfer_Asset]
	@Asset_Search_ID AS INT = null,
	@Asset_ID AS VARCHAR(10) = null,
	@Transfer_Site_ID AS INT,
	@Emp_ID AS VARCHAR(11),
	@Date AS DateTime
AS
BEGIN
	DECLARE @ErrorCount AS INT
	DECLARE @AssetTransferCount AS INT
	DECLARE @ErrorMessage AS VARCHAR(1000)
	DECLARE @AssetTempTbl TABLE(
		Asset_ID int
	)

	--Build List of selected asset to transfer
	INSERT INTO @AssetTempTbl
	select 
		distinct v.Asset_ID
	from v_Asset_Master_List v 
	left join Asset_Search_Detail d 
		on v.Asset_ID = d.Asset_ID
	where 1=1
		and d.Is_Checked = case when @Asset_Search_ID is not null then 1 else d.Is_Checked end
		and d.Asset_Search_ID = isnull(@Asset_Search_ID, d.Asset_Search_ID) 
		and v.Asset_ID = isnull(@Asset_ID, v.Asset_ID)

	--Set Variable count
	SET @ErrorCount = (select count(*) from dbo.ValidateAssetSearchTransfer(@Asset_Search_ID, @Transfer_Site_ID, @Asset_ID))
	SET @AssetTransferCount = (select count(*) from @AssetTempTbl)

	IF @ErrorCount = 0 AND @AssetTransferCount > 0
		BEGIN
			--Audit Log for Asset_Bin_Mapping 
			insert into Audit_Log
			select 
				'Asset_Bin_Mapping' as Tbl_Name,
				bm.ID as Primary_Key_ID,
				'Bin_ID' as Column_Name,
				'Bin ID' as Column_Name_Desc,
				bm.Bin_ID as Old_Value,
				cast(b.ID as varchar(10)) + ' - ' + s.Name + ' Bin #:' + cast(b.Number as varchar(10)) as Old_Value_Desc,
				null as New_Value,
				null as New_Value_Desc,
				@Emp_ID as Emp_ID,
				@Date as Date_Modified

			from Asset_Bin_Mapping bm
			inner join Bin b
				on b.ID = bm.Bin_ID
			inner join CT_Site s
				on s.ID = b.Site_ID
			where 1=1
				and bm.Asset_ID in (
					select * from @AssetTempTbl
				)

			union all

			--Audit Log for Asset_Site_Mapping
			select
				'Asset_Site_Mapping' as Table_Name,
				sm.ID as Primary_Key_ID,
				'Site_ID' as Column_Name,
				'Site ID' as Column_Name_Desc,
				sm.Site_ID as Old_Value,
				isnull(old_site.Short_Name, old_site.Name) as Old_Value_Desc,
				new_site.ID as New_Value,
				isnull(new_site.Short_Name, new_site.Name) as New_Value_Desc,
				@Emp_ID as Emp_ID,
				@Date as Date_Modified
			from Asset_Site_Mapping sm
			inner join CT_Site old_site
				on old_site.ID = sm.Site_ID
			left join CT_Site new_site
				on new_site.ID = @Transfer_Site_ID
			where 1=1
				and sm.Asset_ID in (
					select * from @AssetTempTbl
				)

			--Unassign asset from any bin
			UPDATE Asset_Bin_Mapping
				SET Bin_ID = null
			where Asset_ID in (
				select * from @AssetTempTbl
			)

			--Update Asset_Site_Mapping
			Update Asset_Site_Mapping 
				SET Site_ID = @Transfer_Site_ID
			where Asset_ID in (
				select * from @AssetTempTbl
			)

			select 'Asset Successfully Transferred: ' + cast(@AssetTransferCount as varchar(10))  as msg
		END
	ELSE
		BEGIN
			select 'Error Transfering asset. Error Count: ' + cast(@ErrorCount as varchar(10)) + ' Transfer Asset Attempted Count: ' + cast(@AssetTransferCount as varchar(10)) as msg
		END

END






GO
