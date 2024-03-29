USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Search_Detail]    Script Date: 10/5/2017 11:31:17 AM ******/
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
ALTER TABLE [dbo].[Asset_Search_Detail]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Search_Detail_Asset_Search] FOREIGN KEY([Asset_Search_ID])
REFERENCES [dbo].[Asset_Search] ([ID])
GO
ALTER TABLE [dbo].[Asset_Search_Detail] CHECK CONSTRAINT [FK_Asset_Search_Detail_Asset_Search]
GO
