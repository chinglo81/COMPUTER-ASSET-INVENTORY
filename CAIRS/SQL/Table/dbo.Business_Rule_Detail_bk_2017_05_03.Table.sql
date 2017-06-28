USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Business_Rule_Detail_bk_2017_05_03]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Business_Rule_Detail_bk_2017_05_03](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Business_Rule_ID] [int] NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
