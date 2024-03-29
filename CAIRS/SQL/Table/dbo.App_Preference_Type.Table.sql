USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[App_Preference_Type]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[App_Preference_Type](
	[ID] [int] NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](100) NULL,
	[Is_Active] [bit] NULL,
 CONSTRAINT [PK__App_Pref__3214EC276BB7E6D2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
