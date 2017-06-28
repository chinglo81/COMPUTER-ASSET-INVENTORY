USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Bk_20170522_Audit_Log]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Bk_20170522_Audit_Log](
	[ID] [int] NOT NULL,
	[Table_Name] [varchar](100) NOT NULL,
	[Primary_Key_ID] [int] NOT NULL,
	[Column_Name] [varchar](100) NOT NULL,
	[Column_Name_Desc] [varchar](100) NOT NULL,
	[Old_Value] [varchar](1000) NULL,
	[Old_Value_Desc] [varchar](1000) NULL,
	[New_Value] [varchar](1000) NULL,
	[New_Value_Desc] [varchar](1000) NULL,
	[Emp_ID] [varchar](11) NOT NULL,
	[Date_Modified] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
