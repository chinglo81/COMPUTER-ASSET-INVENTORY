USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Import_Record_Payment]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Import_Record_Payment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Import_Record_History_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NULL,
	[Import_Type_ID] [int] NULL,
	[Price] [decimal](10, 2) NULL,
	[Payments] [decimal](10, 2) NULL,
	[Date] [date] NULL,
 CONSTRAINT [PK_Import_Record_Payment_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
