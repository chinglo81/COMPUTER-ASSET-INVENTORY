USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetUserPreferenceByType]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE  [dbo].[sp_GetUserPreferenceByType]
		@Emp_ID as varchar(11),
		@App_Preference_Type_Code as varchar(100)
AS

Select 
	u.App_Preference_Type_ID,
	t.Code,
	t.Name,
	t.Description,
	t.Is_Active,
	u.Emp_ID,
	u.Preference_Value
from App_Preference_Type t
inner join App_User_Preference u
	on u.App_Preference_Type_ID = t.ID
where 1=1
	and t.Code = @App_Preference_Type_Code
	and u.Emp_ID = @Emp_ID


GO
