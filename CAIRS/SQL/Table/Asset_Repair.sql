USE Asset_Tracking

CREATE TABLE Asset_Repair
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_ID INT NOT NULL,
	Asset_Student_Transaction_ID INT,
	Repair_Type_ID INT NOT NULL,
	Comment VARCHAR(MAX),
	Date_Sent DATE,
	Date_Received DATE,
	Received_By_Emp_ID VARCHAR(11),
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)
