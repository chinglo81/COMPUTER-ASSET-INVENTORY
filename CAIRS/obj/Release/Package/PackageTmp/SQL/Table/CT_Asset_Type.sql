USE Asset_Tracking

CREATE TABLE CT_Asset_Type
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Asset_Base_Type_ID INT NOT NULL,
	Vendor_ID INT,
	Is_Vendor_Req BIT NOT NULL,
	Is_Serial_Req Bit NOT NULL,
	Warranty_Days INT,
	Is_Active BIT NOT NULL
)