USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[CT_Site]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_Site](
	[ID] [int] NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Short_Name] [varchar](25) NULL,
	[School_Messenger_Name] [varchar](100) NULL,
	[School_Messenger_Name_Spanish] [varchar](100) NULL,
	[Description] [varchar](1000) NULL,
	[Fixed_Asset_Loc_Number] [varchar](10) NULL,
	[Fixed_Asset_Loc_Description] [varchar](1000) NULL,
	[Is_Active] [bit] NOT NULL,
	[Is_School_Site] [bit] NULL,
 CONSTRAINT [PK__CT_Site__3214EC272DF3A8EC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_CT_Site_Code] UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
