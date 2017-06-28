USE Asset_Tracking

CREATE TABLE Asset
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Tag_ID VARCHAR(100) NOT NULL,
	Asset_Disposition_ID INT NOT NULL,
	Asset_Condition_ID INT NOT NULL,
	Asset_Type_ID INT NOT NULL,
	Asset_Assignment_Type_ID INT NOT NULL,
	Serial_Number VARCHAR(100),
	Date_Purchased DATE,
	Is_Leased BIT,
	Is_Active BIT NOT NULL,
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME
)
