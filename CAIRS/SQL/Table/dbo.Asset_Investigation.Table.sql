USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Investigation]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Asset_Investigation](
	[Name] [nvarchar](255) NULL,
	[Model] [nvarchar](255) NULL,
	[IP Location] [nvarchar](255) NULL,
	[Serialnumber] [nvarchar](255) NULL
) ON [PRIMARY]

GO
