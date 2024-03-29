USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Load]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Load](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Serial_Number] [varchar](100) NOT NULL,
	[Tag_ID] [varchar](100) NOT NULL,
	[Site_ID] [int] NOT NULL,
	[Site_Desc] [varchar](100) NOT NULL,
	[Asset_Base_Type_ID] [int] NOT NULL,
	[Asset_Base_Type_Desc] [varchar](100) NOT NULL,
	[Asset_Type_ID] [int] NOT NULL,
	[Asset_Type_Desc] [varchar](100) NOT NULL,
	[Purchased_Date] [date] NULL,
	[Is_Loaded] [bit] NULL,
	[Comment] [varchar](1000) NULL,
	[Added_By_EmpID] [varchar](10) NULL,
	[Added_By_Emp_Name] [varchar](100) NULL,
	[Date_Added] [date] NOT NULL,
 CONSTRAINT [PK_Asset_Load] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
