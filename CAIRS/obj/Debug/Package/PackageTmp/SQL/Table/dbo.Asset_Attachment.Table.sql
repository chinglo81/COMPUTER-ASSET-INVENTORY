USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Attachment]    Script Date: 2/3/2017 10:33:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Attachment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NULL,
	[File_Type_ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
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
