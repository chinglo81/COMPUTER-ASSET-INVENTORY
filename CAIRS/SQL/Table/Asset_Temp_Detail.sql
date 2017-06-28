USE Asset_Tracking

CREATE TABLE Asset_Temp_Detail
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Asset_Temp_Header_ID INT NOT NULL,
	Tag_ID VARCHAR(100) NOT NULL,
	Asset_Disposition_ID INT NOT NULL,
	Asset_Condition_ID INT NOT NULL,
	Asset_Type_ID INT NOT NULL,
	Asset_Assignment_Type_ID INT NOT NULL,
	Bin_ID INT,
	Serial_Number VARCHAR(100),
	Date_Purchased DATE,
	Is_Leased BIT,
	Date_Added DATETIME NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL
)
