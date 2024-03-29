USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Edit_Asset]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Edit_Asset]
		@Asset_ID AS INT,
		@Tag_ID AS VARCHAR(100),
		@Serial_Number AS VARCHAR(100)
AS

	--1. Tag ID exist on another asset
	SELECT
		'Tag ID: ' + a.Tag_ID + ' already exist' as Error_Msg
    FROM Asset a
	WHERE 1=1
		and a.Tag_ID = @Tag_ID
	    and a.id <> @Asset_ID

	UNION ALL

	--2. Serial exist on another asset
	SELECT
		'Serial #: ' + a.Serial_Number + ' already exist on Tag ID: ' + dup_serial.Tag_ID as Error_Msg
    FROM Asset a
	left join Asset dup_serial
		on dup_serial.Serial_Number = @Serial_Number
	WHERE 1=1
		and a.Serial_Number = @Serial_Number
	    and a.id <> @Asset_ID

	UNION ALL

	--3. Tag Starting with M for Leased Laptop
	SELECT
		'Tag ID must start with "M" for Leased ' + a.Asset_Base_Type_Desc as Error_Msg
	FROM v_Asset_Master_List a
	WHERE 1=1
		and a.Asset_ID = @Asset_ID
		and a.Is_Leased = 'Yes'
		and a.Asset_Base_Type_ID = 1 --Laptop base type
		and @Tag_ID not like 'm%'

	UNION ALL
	
	--4 Tag ID for Leased Laptop must be 10 characters
	select 
		'Tag ID must be "10" character for Leased ' + a.Asset_Base_Type_Desc as Error_Msg
	from v_Asset_Master_List a
	where 1=1
		and a.Asset_ID = @Asset_ID
		and a.Is_Leased = 'Yes'
		and a.Asset_Base_Type_ID = 1 --Laptop base type'
		and len(@Tag_ID) <> 10

	UNION ALL

	--5 Tag ID must Match Serial for Power Adapter
	select 
			'Tag ID and Serial # must match for ' +  a.Asset_Base_Type_Desc as Message_Error
		from v_Asset_Master_List a
		where 1=1
			and a.Asset_ID = @Asset_ID
			and a.Asset_Base_Type_ID = 3
			and @Tag_ID <> @Serial_Number



GO
