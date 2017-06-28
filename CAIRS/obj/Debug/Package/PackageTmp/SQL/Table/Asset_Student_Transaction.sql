USE Asset_Tracking

--Code tables
CREATE TABLE Asset_Student_Transaction
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_ID INT NOT NULL,
	Student_ID VARCHAR(20) NOT NULL,
	Student_School_Number VARCHAR(3) NOT NULL, 
	School_Year INT NOT NULL, 
	Check_Out_Asset_Condition_ID INT,
	Check_Out_By_Emp_ID VARCHAR(11) NOT NULL, 
	Date_Check_Out DATETIME NOT NULL,
	Check_In_Asset_Condition_ID INT,
	Check_In_By_Emp_ID VARCHAR(11),
	Date_Check_In DATETIME, 
	Comment VARCHAR(MAX)

)