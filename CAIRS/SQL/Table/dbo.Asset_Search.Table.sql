USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Search]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Search](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Filter_Value] [varchar](4000) NULL,
	[Filter_Text] [varchar](4000) NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
