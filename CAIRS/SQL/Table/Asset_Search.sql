USE Asset_Tracking

CREATE TABLE Asset_Search
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	Filter_Value Varchar(4000),
	Filter_Text Varchar(4000),
	Added_By_Emp_ID VARCHAR(11) NOT NULL,
	Date_Added DATETIME,
	Modified_By_Emp_ID VARCHAR(11),
	Date_Modified DATETIME
)