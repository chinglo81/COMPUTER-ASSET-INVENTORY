USE Asset_Tracking

--Code tables
CREATE TABLE CT_Site
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Fixed_Asset_Loc_Number VARCHAR(10),
	Fixed_Asset_Loc_Description VARCHAR(1000),
	Is_Active BIT NOT NULL
)