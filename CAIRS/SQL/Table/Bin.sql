USE Asset_Tracking

CREATE TABLE Bin
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Site_ID INT Not NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Capacity INT,
	Is_Active BIT NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME NOT NULL,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME,
)