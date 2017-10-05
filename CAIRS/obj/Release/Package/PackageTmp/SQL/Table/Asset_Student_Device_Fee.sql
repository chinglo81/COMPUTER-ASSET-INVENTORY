USE Asset_Tracking

CREATE TABLE Asset_Student_Device_Fee
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Student_Device_Fee_ID INT NOT NULL,
	Asset_Student_Transaction_ID INT NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DateTime
)
