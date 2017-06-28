USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Search_Detail]    Script Date: 2/3/2017 10:33:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Asset_Search_Detail](
	[Asset_Search_ID] [int] NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Sort_Order] [int] NOT NULL,
	[Is_Selected] [bit] NOT NULL,
	[Is_Checked] [bit] NULL
) ON [PRIMARY]

GO
