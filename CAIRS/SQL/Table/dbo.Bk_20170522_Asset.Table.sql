USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Bk_20170522_Asset]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Bk_20170522_Asset](
	[ID] [int] NOT NULL,
	[Tag_ID] [varchar](100) NOT NULL,
	[Asset_Disposition_ID] [int] NOT NULL,
	[Asset_Condition_ID] [int] NOT NULL,
	[Asset_Type_ID] [int] NOT NULL,
	[Asset_Assignment_Type_ID] [int] NOT NULL,
	[Serial_Number] [varchar](100) NULL,
	[Date_Purchased] [date] NULL,
	[Is_Leased] [bit] NOT NULL,
	[Is_Active] [bit] NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
