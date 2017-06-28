CREATE TABLE App_User_Preference
(
	ID int IDENTITY(1,1) PRIMARY KEY,
	App_Preference_Type_ID INT NOT NULL,
	Emp_ID VARCHAR(11),
	Preference_Value VARCHAR(100)
)