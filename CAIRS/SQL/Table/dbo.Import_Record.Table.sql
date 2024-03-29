USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Import_Record]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Import_Record](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Import_Config_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NULL,
	[Last] [varchar](100) NULL,
	[First] [varchar](100) NULL,
	[Gr] [varchar](10) NULL,
	[Import_Type_ID] [int] NULL,
	[Import_Type_Desc] [varchar](100) NULL,
	[Price] [decimal](10, 2) NULL,
	[Payments] [decimal](10, 2) NULL,
	[Date] [date] NULL,
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
ALTER TABLE [dbo].[Import_Record]  WITH NOCHECK ADD  CONSTRAINT [FK_Import_Record_Import_Config] FOREIGN KEY([Import_Config_ID])
REFERENCES [dbo].[Import_Config] ([ID])
GO
ALTER TABLE [dbo].[Import_Record] CHECK CONSTRAINT [FK_Import_Record_Import_Config]
GO
ALTER TABLE [dbo].[Import_Record]  WITH NOCHECK ADD  CONSTRAINT [FK_Import_Record_Import_Type] FOREIGN KEY([Import_Type_ID])
REFERENCES [dbo].[Import_Type] ([ID])
GO
ALTER TABLE [dbo].[Import_Record] CHECK CONSTRAINT [FK_Import_Record_Import_Type]
GO
