USE Asset_Tracking

CREATE TABLE App_Preference_Type
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(100) NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(100),
	Is_Active BIT
)