USE Asset_Tracking

CREATE TABLE Asset_Student_Notification
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Asset_Student_Transaction_ID INT NOT NULL,
	Asset_ID INT NOT NULL,
	Student_ID VARCHAR(20) NOT NULL,
	Notification_Type_ID INT NOT NULL,
	Sent_To VARCHAR(MAX),
	Date_Sent DATETIME
	
)