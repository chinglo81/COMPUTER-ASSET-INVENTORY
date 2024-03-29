USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Import_Type]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Import_Type](
	[ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Price] [decimal](10, 2) NULL,
	[Description] [varchar](max) NULL,
	[Fee_Code] [varchar](2) NULL,
	[Is_Active] [bit] NOT NULL,
 CONSTRAINT [PK__Import_T__3214EC2701746E0E] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
