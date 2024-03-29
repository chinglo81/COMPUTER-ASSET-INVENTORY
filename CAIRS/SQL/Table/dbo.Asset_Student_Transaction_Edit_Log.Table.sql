USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Student_Transaction_Edit_Log]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Student_Transaction_Edit_Log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_Student_Transaction_ID] [int] NOT NULL,
	[Edit_Reason] [varchar](max) NULL,
	[Change_Log] [xml] NULL,
	[Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
