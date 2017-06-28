USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Student_Device_Coverage_Import]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Student_Device_Coverage_Import](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Student_Device_Coverage_Config_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NULL,
	[Last_Name] [varchar](100) NULL,
	[First_Name] [varchar](100) NULL,
	[Description] [varchar](1000) NULL,
	[Price] [float] NULL,
	[Payment] [float] NULL,
	[Date_Paid] [date] NULL,
	[Is_Processed] [bit] NULL,
	[Is_Imported] [bit] NULL,
	[Comment] [varchar](1000) NULL,
	[Date_Imported] [datetime] NULL,
 CONSTRAINT [PK__Student___3214EC274B7E53EC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
