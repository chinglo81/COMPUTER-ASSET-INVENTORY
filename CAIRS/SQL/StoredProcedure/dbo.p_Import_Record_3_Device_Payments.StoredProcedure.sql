USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Import_Record_3_Device_Payments]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[p_Import_Record_3_Device_Payments] 
(
	@DateTime AS DateTime
)

AS
	--Table for list of records that will be used to insert into student coverage
	DECLARE @Tbl_Processing_Record as TABLE(
		Import_Record_ID INT
	)
	
	--Temp table to send records to MOSIS
	DECLARE @Tbl_Records_Sent_To_StudentFees as TABLE(
		Import_Record_ID INT,
		StudentID VARCHAR(100),
		SchoolNum VARCHAR(100),
		TransactionDate DateTime,
		TransactionType VARCHAR(2),
		Eligibility VARCHAR(1),
		TransactionAmount decimal(10,2),
		Description VARCHAR(MAX),
		ParentGuardian VARCHAR(1000),
		Status VARCHAR(100),
		DateEntered DATETIME,
		EnteredBy VARCHAR(11),
		DateModified DATETIME,
		ModifiedBy VARCHAR(11),
		IsActive BIT
	)


	--insert records processing
	insert into @Tbl_Processing_Record
	select 
		i.ID
	from Import_Record i 
	where 1=1
		and i.Is_Processed is null --Only records that have not been processed
		and i.Import_Type_ID in (
			2,	--Damaged Device
			3,	--Lost/Stolen Device
			4	--Lost/Stolen Power Adapter
		)


	--Insert Records to temp table
	insert into @Tbl_Records_Sent_To_StudentFees
	select 
		import.ID,
		import.Student_ID,
		stu.SasiSchoolNum as School_Number,
		import.Date as Transaction_Date,
		iType.Fee_Code as Transaction_Type,
		fc.EligibilityFlag as Eligibility_Flag,
		import.Payments as Transaction_Amount, 
		'ASBWorks - Imported Technology Payment' as Description,
		stu.Parent_GuardianName as ParentGuardian,
		null as Status,
		@DateTime as DateEntered,
		'SYSTEM' as Entered_By, 
		null as Date_Modified,
		null as Modified_By,
		1 as Is_Active
	from @Tbl_Processing_Record t
	inner join Import_Record import
		on import.ID = t.Import_Record_ID
	inner join Import_Type iType
		on iType.ID = import.Import_Type_ID
	inner join mcs.dbo.FeeCodes fc
		on fc.FeeCode = iType.Fee_Code
	inner join Datawarehouse.dbo.Student stu
		on stu.StudentId = import.Student_ID


	--Insert Records into MOSIS Fee
	insert into mcs.dbo.StudentFees
	select 
		t.StudentID,
		t.SchoolNum,
		t.TransactionDate,
		t.TransactionType,
		t.Eligibility,
		t.TransactionAmount,
		t.Description,
		t.ParentGuardian,
		t.Status,
		null,
		null,
		null,
		t.DateEntered,
		t.EnteredBy,
		t.DateModified,
		t.ModifiedBy, 
		t.IsActive
	from @Tbl_Records_Sent_To_StudentFees t

	--Archived payment data that was sent to MOSIS to prevent duplication
	insert into Import_Record_Payment
	select 
		r.ID,
		r.Student_ID,
		r.Import_Type_ID,
		r.Price,
		r.Payments,
		r.Date
	from Import_Record r
	where r.ID in (
		select t.Import_Record_ID from @Tbl_Records_Sent_To_StudentFees t --Total Success Records
	)


	--Update records submitted successfully
	update Import_Record
		set 
			Is_Processed = 1,
			Is_Imported = 1,
			Date_Imported = @DateTime,
			Comment = 'Successfully Imported'
	from Import_Record i 
	where i.ID in (
		select t.Import_Record_ID from @Tbl_Records_Sent_To_StudentFees t
	)

	--Update unsucessful records missed due to additional joins above
	update Import_Record
		set 
			Is_Processed = 1,
			Is_Imported = 0,
			Date_Imported = @DateTime,
			Comment = 'Failed: Investigate Stored Proce: Asset_Tracking.dbo.p_Import_Record_3_Device_Payments'
	from Import_Record i 
	where 1=1
		and i.ID in (
			select * from @Tbl_Processing_Record --Total Processing Records
		)
		and i.ID NOT IN (
			select t.Import_Record_ID from @Tbl_Records_Sent_To_StudentFees t --Total Success Records
		)
		

GO
