USE Asset_Tracking

CREATE TABLE Asset_Student_Transaction_Interaction
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_Student_Transaction_ID INT NOT NULL,
	Interaction_Type_ID INT NOT NULL,
	Comment VARCHAR(1000),
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)
