USE Asset_Tracking

CREATE TABLE Asset_CheckOut_Exception_Student_Header
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Asset_Base_Type_ID INT NOT NULL,
	Max_Check_Out_Override INT NOT NULL,
	Is_Active BIT NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)
