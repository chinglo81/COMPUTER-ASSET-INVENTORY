USE Asset_Tracking

CREATE TABLE Asset_Student_Fee
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Student_Device_Fee_ID INT,
	Asset_Student_Transaction_ID INT NOT NULL,
	Student_ID VARCHAR(20) NOT NULL,
	Asset_ID INT NOT NULL,
	Asset_Base_Type_ID INT NOT NULL,
	Asset_Type_ID INT NOT NULL,
	Asset_Disposition_Type_ID INT NOT NULL, 
	Asset_Disposition_Type_Desc VARCHAR(100) NOT NULL,
	Is_Police_Report_Provided BIT NOT NULL,
	Fee_Amount FLOAT, 
	Is_Processed BIT NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)
