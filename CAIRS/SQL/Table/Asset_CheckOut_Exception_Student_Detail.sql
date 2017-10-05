USE Asset_Tracking

CREATE TABLE Asset_CheckOut_Exception_Student_Detail
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Asset_CheckOut_Exception_Student_Header_ID INT NOT NULL,
	Student_ID varchar(20) NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL
)
