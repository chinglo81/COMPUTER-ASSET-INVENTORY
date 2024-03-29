USE [security]
GO
/****** Object:  StoredProcedure [dbo].[sp_Insert_ApplicationExceptions]    Script Date: 1/20/2017 8:37:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 1/20/2017 8:33:46 AM
-- =============================================

CREATE PROCEDURE [dbo].[sp_Insert_ApplicationExceptions]
	@applicationid AS INT,
	@pagename AS VARCHAR(500) ,
	@exceptiontype AS VARCHAR(200) ,
	@stacktrace AS VARCHAR(8000) ,
	@exceptionmessage AS VARCHAR(8000) ,
	@exceptiondate AS VARCHAR(30),
	@networklogin AS VARCHAR(100) ,
	@machinename AS VARCHAR(50) ,
	@ipaddress AS VARCHAR(20) ,
	@handled AS VARCHAR(30),
	@resolved AS VARCHAR(30)
AS
BEGIN
	-- Return Value
	DECLARE @returnid int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements
	SET NOCOUNT ON; 
	
	INSERT INTO security.dbo.ApplicationExceptions(
				applicationid,
				pagename,
				exceptiontype,
				stacktrace,
				exceptionmessage,
				exceptiondate,
				networklogin,
				machinename,
				ipaddress,
				handled,
				resolved
	)
			SELECT 
				@applicationid,
				@pagename,
				@exceptiontype,
				@stacktrace,
				@exceptionmessage,
				@exceptiondate,
				@networklogin,
				@machinename,
				@ipaddress,
				@handled,
				@resolved

	SET @returnid = SCOPE_IDENTITY()
	SELECT @returnid
END


