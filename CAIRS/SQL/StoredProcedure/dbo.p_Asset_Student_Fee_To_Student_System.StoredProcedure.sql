USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Asset_Student_Fee_To_Student_System]    Script Date: 6/28/2017 11:00:57 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Asset_Student_Fee_To_Student_System] AS

DECLARE @Date_Processed as DATETIME = GETDATE()

--Temp Table to hold a the list of items to process
DECLARE @TBL_Student_Asset_Fee as TABLE (
		Asset_Student_Fee_ID INT,
		StudentID VARCHAR(100),
		SchoolNum VARCHAR(100),
		TransactionDate DateTime,
		TransactionType VARCHAR(2),
		Eligibility VARCHAR(1),
		TransactionAmount NUMERIC(9,2),
		Description VARCHAR(MAX),
		ParentGuardian VARCHAR(1000),
		Status VARCHAR(100),
		DateEntered DATETIME,
		EnteredBy VARCHAR(11),
		DateModified DATETIME,
		ModifiedBy VARCHAR(11),
		IsActive BIT
)

INSERT INTO @TBL_Student_Asset_Fee
select
	f.ID,
	f.Student_ID,
	stu.SasiSchoolNum, 
	f.Date_Added as TransactionDate,
	fc.FeeCode,
	fc.EligibilityFlag,
	abs(f.Owed_Amount) as TransActionAmount,
	--fc.FeeType as FeeDescription,
	'Asset Site: ' + s.Short_Name + + CHAR(10) + 'Tag ID: ' + a.Tag_ID as FeeDescription,
	stu.Parent_GuardianName,
	NULL as Status,
	@Date_Processed as DateEntered,
	f.Added_By_Emp_ID,
	NULL as DateModified,
	Null as ModifiedBy,
	1 as IsActive

from Asset_Student_Fee f with (nolock)
inner join Asset a with (nolock)
	on a.ID = f.Asset_ID
inner join Asset_Site_Mapping sm
	on sm.Asset_ID = a.ID
inner join CT_Site s
	on s.ID = sm.Site_ID
inner join CT_Fee_Type_Mapping fm with (nolock)
	on fm.Asset_Disposition_ID = f.Asset_Disposition_ID
	and fm.Asset_Base_Type_ID = f.Asset_Base_Type_ID
inner join MCS.dbo.FeeCodes fc with (nolock)
	on fc.FeeCode = fm.Fee_Code
inner join Datawarehouse.dbo.Student stu with (nolock)
	on stu.StudentId = f.Student_ID
where f.Date_Processed_Fee is null


--Add to Student Fees Table in Student System
--Only when amount is greater than 0 (Zero)
insert into mcs.dbo.StudentFees
select 
	tbl.StudentID,
	tbl.SchoolNum,
	tbl.TransactionDate,
	tbl.TransactionType,
	tbl.Eligibility,
	tbl.TransactionAmount,
	tbl.Description,
	tbl.ParentGuardian,
	tbl.Status,
	tbl.DateEntered,
	tbl.EnteredBy,
	tbl.DateModified,
	tbl.ModifiedBy,
	tbl.IsActive
from @TBL_Student_Asset_Fee tbl
where tbl.TransactionAmount > 0

--Update Processing Date
update Asset_Student_Fee
	SET
		Date_Processed_Fee = @Date_Processed
WHERE ID in (
	select 
		tbl.Asset_Student_Fee_ID
	from @TBL_Student_Asset_Fee tbl
)


GO
