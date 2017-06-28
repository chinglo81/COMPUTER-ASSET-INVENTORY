USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Business_Rule_bk_2017_05_03]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Business_Rule_bk_2017_05_03](
	[ID] [int] NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Table_Name] [varchar](100) NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
