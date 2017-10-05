USE Asset_Tracking

CREATE TABLE Asset_Site_Mapping_Audit_Log
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_Site_Mapping_ID INT NOT NULL,
	Column_Name VARCHAR(100) NOT NULL,
	Old_Value VARCHAR(1000),
	New_Value VARCHAR(1000),
	Emp_ID VARCHAR(11) NOT NULL,
	Date_Modified DATETIME NOT NULL
)
