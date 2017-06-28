USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Bk_20170522_Asset_Bin_Mapping]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Bk_20170522_Asset_Bin_Mapping](
	[ID] [int] NOT NULL,
	[Bin_ID] [int] NULL,
	[Asset_ID] [int] NOT NULL,
	[Date_Added] [datetime] NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
