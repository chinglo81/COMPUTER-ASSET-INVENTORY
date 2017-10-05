USE Asset_Tracking

CREATE TABLE Audit_Log
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Table_Name VARCHAR(100) NOT NULL,
	Primary_Key_ID INT NOT NULL,
	Column_Name VARCHAR(100) NOT NULL,
	Column_Name_Desc Varchar(100) NOT NULL,
	Old_Value VARCHAR(1000),
	Old_Value_Desc VARCHAR(1000),
	New_Value VARCHAR(1000),
	New_Value_Desc VARCHAR(1000),
	Emp_ID VARCHAR(11) NOT NULL,
	Date_Modified DATETIME NOT NULL
)
