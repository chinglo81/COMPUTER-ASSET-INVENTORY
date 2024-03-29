USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Student_Transaction]    Script Date: 2/3/2017 10:33:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Student_Transaction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NOT NULL,
	[Student_School_Number] [varchar](3) NOT NULL,
	[School_Year] [int] NOT NULL,
	[Check_Out_Asset_Condition_ID] [int] NULL,
	[Check_Out_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Check_Out] [datetime] NOT NULL,
	[Check_In_Asset_Condition_ID] [int] NULL,
	[Check_In_By_Emp_ID] [varchar](11) NULL,
	[Date_Check_In] [datetime] NULL,
	[Comment] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
