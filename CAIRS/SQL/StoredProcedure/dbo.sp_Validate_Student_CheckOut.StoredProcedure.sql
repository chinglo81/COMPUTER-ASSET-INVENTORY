USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Validate_Student_CheckOut]    Script Date: 10/5/2017 11:32:27 AM ******/
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


--Used to make sure asset site matches enrolled site
DECLARE @Tbl_Student_Enroll_Schools as TABLE(
	School_Code VARCHAR(3)
)

--Get the list of school student may be enrolled at
insert into @Tbl_Student_Enroll_Schools
select 
	stu.SasiSchoolNum as Site_Code
from Datawarehouse.dbo.Student stu with (nolock)
where stu.StudentId = @Student_ID

union 

select 
	e.SchoolAttn as Site_Code
from datawarehouse.dbo.Student_Enrollment e with (nolock)
where 1=1 
	and e.StudentId = @Student_ID
	and e.HS = 1
	and GETDATE() between e.EffDate and e.EndDate



-----------------------------------------------------------------------------------------------------------------------------------------------------
--Validation SUMMARY for Student Checkout
--1. Student is not active
--2. Student is not highschool grade level - REMOVED 2017-06-12 CLO - Not needed anymore because it will match against enrollment record
--3. Student Site mistmatch Asset Site
--4. Check against CT_BaseType Max_Check_Out for max check out allowed.
--5. Check to see if the tag exist
--6. Check to see if the tag is inactive
--7. Check to see if asset disposition is allowed to be checkout
--8. Serial Number Required for Asset_Base_type = 'Laptop'
--9. Serial Number must must be associated to tag_id for Asset_Base_Type = 'Laptop'
-----------------------------------------------------------------------------------------------------------------------------------------------------
--1. Student is not active
select 
	'<li>Student is Inactive and cannot checkout assets</li>' as Error
from Datawarehouse.dbo.Student s with (nolock)
where s.StudentId = @Student_ID
and s.StudentStatus IS NOT NULL

union all

--3. Student Site mistmatch Asset Site 
select 
	'<li>Student school (' + sch.ShortName + ') ' + + ' mismatch with Asset Site (' + v.Asset_Site_Desc + ')</li>' as Error
	/*
	stu_info.School_Code as Student_School_Code,
	sch.ShortName as Student_School_Desc,
	v.Asset_Site_Code,
	v.Asset_Site_Desc*/
from v_Asset_Master_List v with (nolock)
cross join @Tbl_Student_Enroll_Schools stu_info
left join Datawarehouse.dbo.School sch with (nolock)
	on stu_info.School_Code = sch.SasiSchoolNum

where v.Tag_ID in (
	select Tag_ID from @Tbl_Tag_IDs
)
and v.Asset_Site_Code not in (
	select School_Code from @Tbl_Student_Enroll_Schools
)

union all

/*
select 
	'<li>Student school (' + case when cur_sch.ShortName is not null then cur_sch.ShortName else stuSchool.ShortName end + ') ' + + ' mismatch with Asset Site (' + a.Asset_Site_Desc + ')</li>' as Error
from Datawarehouse.dbo.Student stu  with (nolock)
inner join Datawarehouse.dbo.School stuSchool  with (nolock)
	on stuSchool.SchoolNum = stu.SasiSchoolNum
--Join to get current enrollment
left join (
	select 
		e.StudentId,
		e.SchoolAttn
	from datawarehouse.dbo.Student_Enrollment e  with (nolock)
	where 1=1 
		and e.HS = 1
		and GETDATE() between e.EffDate and e.EndDate
) current_enroll_school
	on current_enroll_school.StudentId = stu.StudentId
left join Datawarehouse.dbo.School cur_sch  with (nolock)
	on cur_sch.SasiSchoolNum = current_enroll_school.SchoolAttn
	and cur_sch.SasiSchoolNum <> stuSchool.SasiSchoolNum
cross join v_Asset_Master_List a  with (nolock)

where 1=1
	and stu.StudentId = @Student_ID -- Match Student ID
	and a.Tag_ID in (select Tag_ID from @Tbl_Tag_IDs)
	and case 
			when cur_sch.SasiSchoolNum is not null then cur_sch.SasiSchoolNum 
			else stuSchool.SasiSchoolNum 
		end not in (
			select 
				sm.Code
			from v_Asset_Master_List t  with (nolock)
			left join v_Asset_Site_Mapping sm  with (nolock)
				on sm.CT_Site_ID = t.Asset_Site_ID 
			where t.Tag_ID in (
				select Tag_ID from @Tbl_Tag_IDs
			)
		)

union all*/
	
--4. Check agains CT_BaseType Max_Check_Out and Exception Table
select 
	'<li>Maximum allowed checkout for ' + amas.Asset_Base_Type_Desc + ' has been reached (' + cast(case when stu.DisabilityCode is not null and stu.DisabilityCode > 0 then bt.Max_Check_Out_Special_Ed else bt.Max_Check_Out end as varchar(100))  + ').</li>'  as Error
	/*
	amas.Asset_Base_Type_ID,
	amas.Asset_Base_Type_Desc,
	case when stu.DisabilityCode is not null and stu.DisabilityCode > 0 then bt.Special_Ed_Max_Check_Out else bt.Max_Check_Out end as Base_Type_Checkout_Amt,
	count(*) as Total_Check_Out*/

from v_Asset_Master_List amas  with (nolock)
inner join CT_Asset_Base_Type bt  with (nolock)
	on bt.id = amas.Asset_Base_Type_ID 
cross join (
	select * 
	from Datawarehouse.dbo.Student with (nolock)
	where StudentId = @Student_ID
) stu
	
where 1=1
	and amas.Tag_ID in (
		--current batch
		select Tag_ID from @Tbl_Tag_IDs
		
		union all

		--asset that has already been checkout
		select --Get the tags that is already checked out
			a.Tag_ID
		from Asset_Student_Transaction astu with (nolock)
		inner join asset a with (nolock)
			on astu.Asset_ID = a.ID
		where astu.Student_ID = @Student_ID
			and astu.Date_Check_In is null
			and a.Asset_Disposition_ID = 1 --Assigned
	)

group by
	amas.Asset_Base_Type_ID,
	amas.Asset_Base_Type_Desc,
	case when stu.DisabilityCode is not null and stu.DisabilityCode > 0 then bt.Max_Check_Out_Special_Ed else bt.Max_Check_Out end

having count(*) > case when stu.DisabilityCode is not null and stu.DisabilityCode > 0 then bt.Max_Check_Out_Special_Ed else bt.Max_Check_Out end

union all

--5. Check to see if the tag exist
SELECT 
	'<li>Asset with Tag ID: ' + a.Tag_ID + ' not found. Please add this asset before checkout</li>' as Error  
FROM @Tbl_Tag_IDs a
LEFT JOIN v_Asset_Master_List am  with (nolock)
	on am.Tag_ID = a.Tag_ID
where 1=1 
	and am.Tag_ID is null
	and a.Tag_ID <> ''

union all

--6. Check to see if the tag is inactive
SELECT 
	'<li>Asset with Tag ID: ' + a.Tag_ID + ' is inactive. You must active this asset before checkout</li>'
FROM @Tbl_Tag_IDs a
inner JOIN v_Asset_Master_List am  with (nolock)
	on am.Tag_ID = a.Tag_ID
where 
	am.Is_Active = 0

union all

--7. Check to see if asset disposition is allowed to be checkout
select top 1
	'<li>Disposition of Asset is "' + disp.Name + '". You cannot check out this asset</li>'  
from Asset a  with (nolock)
inner join CT_Asset_Disposition disp  with (nolock)
	on disp.ID = a.Asset_Disposition_ID
where 1=1
	and a.Tag_ID IN (
		SELECT Tag_ID FROM @Tbl_Tag_IDs
	)
	and a.Is_Active = 1
	and disp.Code not in (
		select distinct
			d.Code
		from Business_Rule b  with (nolock)
		inner join Business_Rule_Detail d  with (nolock)
			on d.Business_Rule_ID = b.ID
		where b.Code = 'Disp_Allow_CheckOut'
			and b.Table_Name = 'CT_Asset_Disposition'
	)

union all

--8. Serial Number Required for Asset_Base_type = 'Laptop'
select 
	'<li>Serial Number is Required for "' + v.Asset_Base_Type_Desc + '". </li>'  
from v_Asset_Master_List v  with (nolock)
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
from v_Asset_Master_List v  with (nolock)
where 1=1
	and v.Is_Active = 1 --Must be active
	and v.Asset_Base_Type_ID = 1 --Laptop
	and v.Tag_ID IN (
		SELECT Tag_ID FROM @Tbl_Tag_IDs where ID = (select max(id) from @Tbl_Tag_IDs) --only match against the most recent tag id
	)
	and v.Serial_Number <> isnull(@Serial_Number, v.Serial_Number)
	and @Serial_Number <> ''

union all

--10 Students not allowed for checking out any assets
select 
	'<li>Student (' + Datawarehouse.dbo.getStudentNameById(stu.StudentId) + ' ' + stu.StudentId + ') not allowed to checkout any assets. <br> Non-Permitted Reason: '
	+ stu.Non_Permit_Reason
	+ '</li>'
from v_Non_Permitted_Student stu with (nolock)
where 1=1
	and stu.StudentId = @Student_ID

union all

--11 Student has to pays fees before getting laptop before school starts
select 
	/*f.studentid,
	sum(case when f.IsCredit = 1 then f.TransactionAmount else 0 end) as Total_Payment_Amount,
	sum(case when f.IsCredit = 0 then f.TransactionAmount else 0 end) as Total_Amount,
	sum(case when f.IsCredit = 0 then f.TransactionAmount else 0 end) - sum(case when f.IsCredit = 1 then f.TransactionAmount else 0 end) as Balance*/
	'Student (' + datawarehouse.dbo.getStudentNameById(f.studentid) +  ' ' + f.studentid + ') owes $' + cast(sum(case when f.IsCredit = 0 then f.TransactionAmount else 0 end) - sum(case when f.IsCredit = 1 then f.TransactionAmount else 0 end) as varchar(100)) + ' . The balance must be paid before the student can checkout any asset(s).'
from mcs.dbo.vStudentFee f
inner join Datawarehouse.dbo.Student stu
	on f.studentid = stu.StudentId

where 1=1
	and f.studentid = @Student_ID
	and cast(getdate() as date) < datawarehouse.dbo.getCurrentYearStartDate(getdate()) --2017-08-14
	and f.FeeIsActive = 1

group by
	f.studentid
having sum(case when f.IsCredit = 0 then f.TransactionAmount else 0 end) - sum(case when f.IsCredit = 1 then f.TransactionAmount else 0 end) > 0
GO
