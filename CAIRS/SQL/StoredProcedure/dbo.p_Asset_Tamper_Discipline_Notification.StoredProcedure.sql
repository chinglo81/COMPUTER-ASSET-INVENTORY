USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Asset_Tamper_Discipline_Notification]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Asset_Tamper_Discipline_Notification] AS

	DECLARE @Cursor CURSOR
	DECLARE @MSG_BODY VARCHAR(MAX)
	DECLARE @MSG_SUBJECT VARCHAR(1000)
	DECLARE @Recipients VARCHAR(1000)
	DECLARE @Today DATETIME = GETDATE()

	--Use for column values
	DECLARE @Asset_Tamper_ID INT
	DECLARE @Student VARCHAR(1000)
	DECLARE @Grade VARCHAR(10)
	DECLARE @Student_School VARCHAR(100)
	DECLARE @Comment VARCHAR(MAX)
	DECLARE @Tag_ID VARCHAR(100)
	DECLARE @Asset_Site VARCHAR(100)
	DECLARE @Asset_Base_Type VARCHAR(100)
	DECLARE @Asset_Type VARCHAR(100)
	DECLARE @Tampered_Date VARCHAR(100) 
	DECLARE @QA_SendNotification VARCHAR(MAX)
	DECLARE @Dicpline_SendNotification VARCHAR(MAX)
	DECLARE @Attachment VARCHAR(MAX)
	DECLARE @PROD_Referral_Link VARCHAR(MAX)
	DECLARE @QA_Referral_Link VARCHAR(MAX)
	DECLARE @PROD_CreateIncident_Link VARCHAR(MAX)
	DECLARE @QA_CreateIncident_Link VARCHAR(MAX)
	
	SET @Cursor = CURSOR FAST_FORWARD 
	FOR 
		select
			tamp.ID as Asset_Tamper_ID,
			Datawarehouse.dbo.getStudentNameById(tamp.Student_ID) +  ' (' + tamp.Student_ID + ')' as Student_Name_And_ID,
			stu.Grade,
			sch.ShortName as Student_School,
			tamp.Comment,
			v.Tag_ID,
			v.Asset_Site_Desc,
			v.Asset_Base_Type_Desc,
			v.Asset_Type_Desc,
			tamp.Date_Added,
			security.dbo.getEmalNotificationUserListByNotificationTypeAndSite('QA', '', '; ') as QA_SendNotificationTo,
			security.dbo.getEmalNotificationUserListByNotificationTypeAndSite('MSR', dbo.PadLeft(v.Asset_Site_Code,4,'0'), ';') as Displine_Notification_To,
			dbo.GetTamperAttachmentForEmail(tamp.id) as Attachments,
			'http://webapps/apps/StudentSystem/StudentDisciplinePage.aspx?disctype=1&studentid=' + tamp.Student_ID as Prod_Referral_Link,
			'http://mcs-webqa/apps/StudentSystem/StudentDisciplinePage.aspx?disctype=1&studentid=' + tamp.Student_ID as QA_Referral_Link,
			'http://webapps/apps/StudentSystem/StudentDisciplineIncidentForm.aspx?disctype=1&studentid=' + tamp.Student_ID as Prod_Create_Incident_Link,
			'http://mcs-webqa/apps/StudentSystem/StudentDisciplineIncidentForm.aspx?disctype=1&studentid=' + tamp.Student_ID as QA_Create_Incident_Link
	
		from Asset_Tamper tamp with (nolock)
		inner join v_Asset_Master_List v with (nolock)
			on v.Asset_ID = tamp.Asset_ID
		inner join Datawarehouse.dbo.Student stu with (nolock)
			on stu.StudentId = tamp.Student_ID
		inner join Datawarehouse.dbo.School sch with (nolock)
			on sch.SchoolNum = stu.SasiSchoolNum

		where tamp.Date_Processed is null

	OPEN @Cursor 
	FETCH NEXT FROM @Cursor 
	
	INTO @Asset_Tamper_ID,
		 @Student,
		 @Grade,
		 @Student_School,
		 @Comment,
		 @Tag_ID,
		 @Asset_Site,
		 @Asset_Base_Type,
		 @Asset_Type,
		 @Tampered_Date,
		 @QA_SendNotification,
		 @Dicpline_SendNotification,
		 @Attachment,
		 @PROD_Referral_Link,
		 @QA_Referral_Link,
		 @PROD_CreateIncident_Link,
		 @QA_CreateIncident_Link

	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	SET @MSG_BODY = 
	' 
	The student listed below tampered with the device shown. 
	<br><br>
	Offense code “48900(f) – Tampered with student device” should be assigned to this student.
	<br>
	<br>
	<h3>STUDENT INFO</h3>
	&nbsp;&nbsp;&nbsp;<strong>School: </strong>' + @Student_School + '
	<br>
	&nbsp;&nbsp;&nbsp;<strong>Student: </strong>' + @Student +
	'<br>
	&nbsp;&nbsp;&nbsp;<strong>Grade: </strong>' + @Grade + '
	<br><br>
	&nbsp;&nbsp;&nbsp;<a href=' + CASE WHEN @@SERVERNAME = 'RENO-SQLIS' THEN  + @PROD_Referral_Link else @QA_Referral_Link end + '>Click here to view referral history</a> 
	<br>
	&nbsp;&nbsp;&nbsp;<a href=' + CASE WHEN @@SERVERNAME = 'RENO-SQLIS' THEN  + @PROD_CreateIncident_Link else @QA_CreateIncident_Link end + '>Click here to Create Incident</a> 
	<br><br>
	<h3>DEVICE INFO</h3>
	&nbsp;&nbsp;&nbsp;<strong>Asset Site: </strong>' + @Asset_Site + '
	<br>
	&nbsp;&nbsp;&nbsp;<strong>Tag ID: </strong>' + @Tag_ID + '
	<br>
	&nbsp;&nbsp;&nbsp;<strong>Asset Type: </strong>' + @Asset_Type + ' (' + @Asset_Base_Type + ')
	<br>
	&nbsp;&nbsp;&nbsp;<strong>Tampered Date: </strong>' + @Tampered_Date

	SET @Recipients = CASE WHEN @@SERVERNAME = 'RENO-SQLIS' THEN  @Dicpline_SendNotification else @QA_SendNotification end
	
	SET @MSG_SUBJECT = 'Tampered with Student Device - ' + @Student 

		EXECUTE msdb.dbo.sp_send_dbmail 
		@profile_name = 'MCSMail',
		@Recipients=@Recipients,
		@subject = @MSG_SUBJECT,
		@Body_Format='HTML',
		@Query_Result_Header=0,
		@body=@MSG_BODY,
		@file_attachments=@Attachment

		UPDATE Asset_Tamper 
			SET Date_Processed = @Today
		WHERE ID = @Asset_Tamper_ID

	FETCH NEXT FROM @Cursor
	
	INTO @Asset_Tamper_ID,
		 @Student,
		 @Grade,
		 @Student_School,
		 @Comment,
		 @Tag_ID,
		 @Asset_Site,
		 @Asset_Base_Type,
		 @Asset_Type,
		 @Tampered_Date,
		 @QA_SendNotification,
		 @Dicpline_SendNotification,
		 @Attachment,
		 @PROD_Referral_Link,
		 @QA_Referral_Link,
		 @PROD_CreateIncident_Link,
		 @QA_CreateIncident_Link

	END



GO
