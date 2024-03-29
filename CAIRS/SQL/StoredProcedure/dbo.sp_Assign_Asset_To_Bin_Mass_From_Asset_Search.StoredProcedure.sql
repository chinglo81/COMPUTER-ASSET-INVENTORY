USE [Asset_Tracking]
GO
/****** Object:  StoredProcedure [dbo].[sp_Assign_Asset_To_Bin_Mass_From_Asset_Search]    Script Date: 10/5/2017 11:32:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Create date: 2/27/2017 9:19:41 PM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Assign_Asset_To_Bin_Mass_From_Asset_Search]
	@Asset_Search_ID AS INT,
	@Bin_ID AS INT,
	@Emp_ID AS VARCHAR(11),
	@Date AS VARCHAR(30)
AS
BEGIN
	IF EXISTS(
		SELECT 1 
		FROM Asset_Search s
		INNER JOIN Asset_Search_Detail d
			on d.Asset_Search_ID = s.ID
		where s.ID = @Asset_Search_ID
			and d.Is_Checked = 1
	)
	BEGIN
		DECLARE @Cursor CURSOR
		DECLARE @Asset_ID as INT

		--Loop thru each of the asset and assign to bin
		SET @Cursor = CURSOR FAST_FORWARD 
			FOR
				select
					d.Asset_ID 
				FROM Asset_Search s
				INNER JOIN Asset_Search_Detail d
					on d.Asset_Search_ID = s.ID
				where s.ID = @Asset_Search_ID
					and d.Is_Checked = 1

			OPEN @Cursor 
			FETCH NEXT FROM @Cursor 

			INTO @Asset_ID

			WHILE @@FETCH_STATUS = 0 
			BEGIN 

			--Execute here
			EXEC dbo.sp_Assign_Asset_To_Bin @Bin_ID,
											@Asset_ID,
											@Emp_ID,
											@Date

			FETCH NEXT FROM @Cursor
			INTO @Asset_ID
			END

	END
END






GO
