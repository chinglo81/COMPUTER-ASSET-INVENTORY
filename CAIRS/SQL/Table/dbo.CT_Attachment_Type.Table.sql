USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[CT_Attachment_Type]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_Attachment_Type](
	[ID] [int] NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Is_Active] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
