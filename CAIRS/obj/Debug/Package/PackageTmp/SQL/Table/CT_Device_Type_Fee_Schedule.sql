USE Asset_Tracking

CREATE TABLE CT_Device_Fee_Type_Schedule
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Asset_Base_Type_ID INT NOT NULL,
	Device_Fee_Type_ID INT NOT NULL,
	Fee_Amount FLOAT NOT NULL,
	Date_Start DATE NOT NULL,
	Date_End DATE
)