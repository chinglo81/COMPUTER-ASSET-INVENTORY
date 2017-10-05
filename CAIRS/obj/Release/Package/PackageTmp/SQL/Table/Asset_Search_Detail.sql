USE Asset_Tracking

CREATE TABLE Asset_Search_Detail
(
	Asset_Search_ID int NOT NULL,
	Asset_ID int NOT NULL, 
	Sort_Order int NOT NULL,
	Is_Selected BIT NOT NULL
)