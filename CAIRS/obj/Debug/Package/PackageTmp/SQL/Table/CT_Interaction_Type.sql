USE Asset_Tracking

CREATE TABLE CT_Interaction_Type
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(10) NOT NULL,
	Name VARCHAR(100) NOT NULL,
	Description VARCHAR(1000),
	Is_Active BIT NOT NULL
)