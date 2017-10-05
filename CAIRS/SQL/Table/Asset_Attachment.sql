USE Asset_Tracking

CREATE TABLE Asset_Attachment
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_ID INT NOT NULL,
	Student_ID VARCHAR(20),
	File_Type_ID INT NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)
