USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[App_Activity]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[App_Activity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[URL] [varchar](2000) NULL,
	[Page_Name] [varchar](1000) NULL,
	[Page_Parameter] [varchar](2000) NULL,
	[Emp_ID] [varchar](11) NULL,
	[Date_Added] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
