USE Asset_Tracking

CREATE TABLE Asset_Bin_Mapping
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Bin_ID INT,
	Asset_ID INT NOT NULL,
	Date_Added Datetime,
	Added_By_Emp_ID VARCHAR(11) NOT NULL
)