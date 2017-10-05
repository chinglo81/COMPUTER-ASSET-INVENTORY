USE Asset_Tracking

CREATE TABLE Asset_Temp_Header
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_Site_ID INT NOT NULL,
	Name VARCHAR(100),
	Description VARCHAR(1000),
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME,
	Has_Submit BIT,
	Date_Submit DATETIME,
	Submitted_By_Emp_ID VARCHAR(11)

)
