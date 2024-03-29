USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[p_Non_Permitted_And_Inactive_Notification]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[p_Non_Permitted_And_Inactive_Notification] 
(
	@RunDateTime AS DateTime
)
AS
	DECLARE @Non_Permitted_And_Inactive_Notification VARCHAR(MAX) = (select dbo.GetNotificationEmailByBusinessRule('Non_Permmited_And_Inactive_Notification',','))
	DECLARE @MSG_BODY VARCHAR(MAX)
	DECLARE @MSG_SUBJECT VARCHAR(1000)
	DECLARE @Attachment VARCHAR(MAX)
	DECLARE @Recipients VARCHAR(1000) = CASE WHEN @@SERVERNAME = 'RENO-SQLIS' THEN @Non_Permitted_And_Inactive_Notification else 'lo.c@monet.k12.ca.us' end
	DECLARE @Today DATETIME = GETDATE()
	DECLARE @Display_Tbl XML
	
	SET @Display_Tbl =	(
							SELECT dbo.CreateHTMLTable(
							(
									select
										mas.Asset_Site_Desc, 
										Datawarehouse.dbo.getStudentNameById(f.student_id) as Student_Name,
										f.Student_ID,
										stu.Grade,
										mas.Asset_Base_Type_Desc,
										mas.Asset_Type_Desc,
										mas.Tag_ID,
										mas.Serial_Number,
										dbo.FormatDateTime(f.Date_Added,'MM/DD/YYYY') as Date_Added,
										f.comment as Reason

									from Asset_Student_Fee f
									inner join v_Asset_Master_List mas
										on f.Asset_ID = mas.Asset_ID
									inner join Datawarehouse.dbo.Student stu
										on f.Student_ID = stu.StudentId

									where 1=1
										and f.Is_Active = 1
										and f.Asset_Disposition_ID in (1010)
										and f.Date_Added = @RunDateTime

									order by
										mas.Asset_Site_Desc,
										Datawarehouse.dbo.getStudentNameById(f.student_id) 
	
									FOR XML RAW,ELEMENTS XSINIL
								)
							)
						)

	IF len(cast(@Display_Tbl as varchar(MAX))) > 0
		BEGIN
			DECLARE @Body_Header VARCHAR(1000) = '<h2>Asset Flagged as "Not Returned"</h2><br><br>'
	
			SET @MSG_SUBJECT = 'CAIRS - Non-Permitted and Inactive Students with "Not Returned" Asset(s) ' + dbo.FormatDateTime(@Today,'MM/DD/YYYY') 

			SET @MSG_BODY = (CAST(@Display_Tbl as VARCHAR(MAX)))

			EXECUTE msdb.dbo.sp_send_dbmail 
			@profile_name = 'MCSMail',
			@Recipients=@Recipients,
			@subject = @MSG_SUBJECT,
			@Body_Format='HTML',
			@Query_Result_Header=0,
			@body=@MSG_BODY,
			@file_attachments=@Attachment
		

		END

	


GO
