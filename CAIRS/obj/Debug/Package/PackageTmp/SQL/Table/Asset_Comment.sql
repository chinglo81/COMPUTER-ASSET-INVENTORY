USE Asset_Tracking

CREATE TABLE Asset_Comment
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_ID INT NOT NULL,
	Comment VARCHAR(MAX),
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)
