USE Asset_Tracking

CREATE TABLE CT_Asset_Base_Type
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(100) NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Max_Check_Out INT NOT NULL,
	Is_Active BIT NOT NULL
)