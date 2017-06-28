USE Asset_Tracking

CREATE TABLE CT_Asset_Disposition
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Fixed_Asset_Disp_Code VARCHAR(10) NULL,
	Fixed_Asset_Disp_Desc VARCHAR(100) NULL,
	Description VARCHAR(1000),
	Allow_Inactivate BIT NOT NULL,
	Allow_CheckOut BIT NOT NULL,
	Allow_CheckIn BIT NOT NULL,
	No_Site_Bin_Restriction BIT NOT NULL, 
	Avail_Option_CheckIn BIT NOT NULL,
	Is_Active BIT NOT NULL
)