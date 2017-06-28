USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Student_CheckOut]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[sp_Validate_Student_CheckOut]
		@Student_ID as varchar(20),
		@Tag_ID as varchar(MAX), 
		@Serial_Number as VARCHAR(100) = null
AS

--Temp table that holds the list of tag ids to process
DECLARE @Tbl_Tag_IDs AS TABLE(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Tag_ID VARCHAR(100) NOT NULL
)
INSERT INTO @Tbl_Tag_IDs
SELECT * FROM dbo.CSVToTable(@Tag_ID,',')



-----------------------------------------------------------------------------------------------------------------------------------------------------
--Validation SUMMARY for Student Checkout
--1. Student is not active
--2. Student is not highschool grade level - REMOVED 2017-06-12 CLO - Not needed anymore because it will match against enrollment record
--3. Student Site mistmatch Asset Site
--4. Check agains CT_BaseType Max_Check_Out and (Asset_CheckOut_Exception_Student_Header,Asset_CheckOut_Exception_Student_Detail) Tables
--5. Check to see if the tag exist
--6. Check to see if the tag is inactive
--7. Check to see if asset disposition is allowed to be checkout
--8. Serial Number Required for Asset_Base_type = 'Laptop'
--9. Serial Number must must be associated to tag_id for Asset_Base_Type = 'Laptop'
-----------------------------------------------------------------------------------------------------------------------------------------------------
--1. Student is not active
select 
	'<li>Student is Inactive and cannot checkout assets</li>' as Error
from Datawarehouse.dbo.Student s
where s.StudentId = @Student_ID
and s.StudentStatus IS NOT NULL

union all
/* REMOVE CLO - Will now match against enrollment
--2. Student is not highschool grade level
select
	'<li>Student must be in highschool' as Error
from Datawarehouse.dbo.Student s
where s.StudentId = @Student_ID
and s.Grade NOT IN ('09', '10','11','12','13')

union all*/

--3. Student Site mistmatch Asset Site or Enroll Scool - MODIFIED 2017-06-12 CLO
select '<li>Student school (' + case when cur_sch.ShortName is not null then cur_sch.ShortName else stuSchool.ShortName end + ') ' + + ' mismatch with Asset Site (' + assetsite.ShortName + ')</li>' as Error
from dbo.Asset a
inner join dbo.Asset_Site_Mapping sm
	on sm.Asset_ID = a.ID
inner join dbo.CT_Site s
	on s.ID = sm.Site_ID
inner join Datawarehouse.dbo.School assetsite
	on assetsite.SchoolNum = s.Code
cross join Datawarehouse.dbo.Student stu
inner join Datawarehouse.dbo.School stuSchool
	on stuSchool.SchoolNum = stu.SasiSchoolNum

--Join to get current enrollment
left join (
	select 
		e.StudentId,
		e.SchoolAttn
	from datawarehouse.dbo.Student_Enrollment e
	where 1=1 
	and e.HS = 1
	and GETDATE() between e.EffDate and e.EndDate
) current_enroll_school
	on current_enroll_school.StudentId = stu.StudentId
left join Datawarehouse.dbo.School cur_sch
	on cur_sch.SasiSchoolNum = current_enroll_school.SchoolAttn
	and cur_sch.SasiSchoolNum <> stuSchool.SasiSchoolNum
	 
where 1=1
	and a.Tag_ID IN (SELECT Tag_ID FROM @Tbl_Tag_IDs)
	and stu.StudentId = @Student_ID
	and s.Code <> case 
					when cur_sch.SasiSchoolNum is not null then cur_sch.SasiSchoolNum 
					else stuSchool.SasiSchoolNum 
				  end

union all
	
--4. Check agains CT_BaseType Max_Check_Out and Exception Table

select
	'<li>Maximum allowed checkout for this type of asset has been reached. Student has ' + cast(case when bType.Max_Check_Out > isnull(hdr.Max_Check_Out_Override, 0) then bType.Max_Check_Out else hdr.Max_Check_Out_Override end as varchar(10)) + ' of this type</li>'  as Error
	/*bType.Name,
	bType.Max_Check_Out,
	isnull(hdr.Max_Check_Out_Override, 0) as Max_Check_Out_Override,
	case when bType.Max_Check_Out > isnull(hdr.Max_Check_Out_Override, 0) then bType.Max_Check_Out else hdr.Max_Check_Out_Override end as Use_Max_CheckOut,
	tags.Total_CheckOut*/
from CT_Asset_Base_Type bType
left join (
	select 
		hdr.Max_Check_Out_Override,
		hdr.Asset_Base_Type_ID,
		hdr.Is_Active
	from Asset_CheckOut_Exception_Student_Header hdr
	left join Asset_CheckOut_Exception_Student_Detail detail
		on detail.Asset_CheckOut_Exception_Student_Header_ID = hdr.ID
	where detail.Student_ID = @Student_ID
		and hdr.Is_Active = 1
) hdr
	on hdr.Asset_Base_Type_ID = bType.ID
left join (
	select
		assignment.Asset_Base_Type_ID,
		count(*) as Total_CheckOut

	from (
		SELECT 
			am.Tag_ID,
			am.Asset_Base_Type_ID
		FROM v_Asset_Master_List am
		where am.Tag_ID in (
			SELECT Tag_ID FROM @Tbl_Tag_IDs
		)

		union 

		select 
			v.Tag_ID,
			v.Asset_Base_Type_ID
		from v_Student_Current_Assignment v

		where v.Student_ID = @Student_ID
	) assignment
	group by
		assignment.Asset_Base_Type_ID
) tags
	on tags.Asset_Base_Type_ID = bType.ID

where bType.Is_Active = 1
and tags.Total_CheckOut > case when bType.Max_Check_Out > isnull(hdr.Max_Check_Out_Override, 0) then bType.Max_Check_Out else hdr.Max_Check_Out_Override end 

union all

/* OLD WAY
select
	'<li>Maximum allowed checkout for this type of asset has been reached. Student has ' + cast(count(*) as varchar(10)) + ' of this type</li>'  as Error
	/* Don't Remove. Used to see current count
	bType.ID,
	bType.Name,
	bType.Max_Check_Out,
	isnull(hdr.Max_Check_Out_Override, 0) as Max_Check_Out_Override,
	count(*) CurrentlyCheckOut,
	case when isnull(bType.Max_Check_Out,0) >= isnull(hdr.Max_Check_Out_Override,0) then isnull(bType.Max_Check_Out,0) else isnull(Max_Check_Out_Override,0) end as BiggestNumber
	*/
from Asset_Student_Transaction astu
inner join Asset a
	on a.ID = astu.Asset_ID
inner join CT_Asset_Type aType
	on aType.ID = a.Asset_Type_ID
inner join CT_Asset_Base_Type bType
	on bType.ID = aType.Asset_Base_Type_ID
inner join ( --match on the incoming tag id
	select 
		bt.ID as Asset_Base_Type_ID
	from Asset a
	inner join CT_Asset_Type t
		on t.ID = a.Asset_Type_ID
	inner join CT_Asset_Base_Type bt
		on bt.ID = t.Asset_Base_Type_ID
	where a.Tag_ID IN (SELECT * FROM dbo.CSVToTable(@Tag_ID,','))
	and a.Is_Active = 1
) SelectedAsset
	on SelectedAsset.Asset_Base_Type_ID = bType.ID
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
--check for exceptions
left join (
	select 
		hdr.Max_Check_Out_Override,
		hdr.Asset_Base_Type_ID,
		hdr.Is_Active
	from Asset_CheckOut_Exception_Student_Header hdr
	left join Asset_CheckOut_Exception_Student_Detail detail
		on detail.Asset_CheckOut_Exception_Student_Header_ID = hdr.ID
	where detail.Student_ID = @Student_ID
		and hdr.Is_Active = 1
) hdr
	on hdr.Asset_Base_Type_ID = bType.ID

where 1=1
	and astu.Student_ID = @Student_ID
	and astu.Date_Check_In is null
	and disp.Code = 1 --disposition must be assigned

group by
	bType.ID,
	bType.Name,
	bType.Max_Check_Out,
	hdr.Max_Check_Out_Override

having count(*) >= case when isnull(bType.Max_Check_Out,0) >= isnull(hdr.Max_Check_Out_Override,0) then isnull(bType.Max_Check_Out,0) else isnull(Max_Check_Out_Override,0) end


union all*/

--5. Check to see if the tag exist
/*
select 
	'<li>Asset with Tag ID: ' + @Tag_ID + ' not found. Please add this asset before checkout</li>' as Error  
where 0 = (select count(*) total from Asset a where a.Tag_ID = @Tag_ID) */
SELECT 
	'<li>Asset with Tag ID: ' + a.Tag_ID + ' not found. Please add this asset before checkout</li>' as Error  
FROM @Tbl_Tag_IDs a
LEFT JOIN v_Asset_Master_List am
	on am.Tag_ID = a.Tag_ID
where 1=1 
	and am.Tag_ID is null
	and a.Tag_ID <> ''

union all

--6. Check to see if the tag is inactive
/*
select top 1
	'<li>Asset with Tag ID: ' + @Tag_ID + ' is inactive. You must active this asset before checkout</li>'
from Asset a
where a.Tag_ID = @Tag_ID
	and a.Is_Active = 0*/
SELECT 
	'<li>Asset with Tag ID: ' + a.Tag_ID + ' is inactive. You must active this asset before checkout</li>'
FROM @Tbl_Tag_IDs a
inner JOIN v_Asset_Master_List am
	on am.Tag_ID = a.Tag_ID
where 
	am.Is_Active = 0

union all

--7. Check to see if asset disposition is allowed to be checkout
select top 1
	'<li>Disposition of Asset is "' + disp.Name + '". You cannot check out this asset</li>'  
from Asset a
inner join CT_Asset_Disposition disp
	on disp.ID = a.Asset_Disposition_ID
where 1=1
	and a.Tag_ID IN (
		SELECT Tag_ID FROM @Tbl_Tag_IDs
	)
	and a.Is_Active = 1
	and disp.Code not in (
		select distinct
			d.Code
		from Business_Rule b
		inner join Business_Rule_Detail d
			on d.Business_Rule_ID = b.ID
		where b.Code = 'Disp_Allow_CheckOut'
			and b.Table_Name = 'CT_Asset_Disposition'
	)

union all

--8. Serial Number Required for Asset_Base_type = 'Laptop'
select 
	'<li>Serial Number is Required for "' + v.Asset_Base_Type_Desc + '". </li>'  
from v_Asset_Master_List v
where 1=1
	and v.Is_Active = 1 --Must be active
	and v.Asset_Base_Type_ID = 1 --Laptop
	and v.Tag_ID IN (
		SELECT Tag_ID FROM @Tbl_Tag_IDs
	)
	and isnull(@Serial_Number,'') = ''

union all

--9. Serial Number must must be associated to tag_id for Asset_Base_Type = 'Laptop'
select 
	'<li>Serial Number (' + @Serial_Number + ') does not belong to Tag ID (' + v.Tag_ID + '). Please do not checkout this asset and investigate the data mismatch.</li>'  
from v_Asset_Master_List v
where 1=1
	and v.Is_Active = 1 --Must be active
	and v.Asset_Base_Type_ID = 1 --Laptop
	and v.Tag_ID IN (
		SELECT Tag_ID FROM @Tbl_Tag_IDs where ID = (select max(id) from @Tbl_Tag_IDs) --only match against the most recent tag id
	)
	and v.Serial_Number <> isnull(@Serial_Number, v.Serial_Number)
	and @Serial_Number <> ''
GO
