USE Asset_Tracking

CREATE TABLE Student_Device_Fee
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Student_ID VARCHAR(20) NOT NULL,
	Device_Fee_Type_ID INT NOT NULL,
	School_Year INT NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DateTime
)
