USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Law_Enforcement]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Law_Enforcement](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Law_Enforcement_Agency_ID] [int] NOT NULL,
	[Officer_First_Name] [varchar](100) NOT NULL,
	[Officer_Last_Name] [varchar](100) NOT NULL,
	[Case_Number] [varchar](100) NOT NULL,
	[Comment] [varchar](max) NULL,
	[Date_Picked_Up] [date] NULL,
	[Date_Returned] [date] NULL,
	[Received_By_Emp_ID] [varchar](11) NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Law_Enforcement]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Law_Enforcement_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Law_Enforcement] CHECK CONSTRAINT [FK_Asset_Law_Enforcement_Asset]
GO
ALTER TABLE [dbo].[Asset_Law_Enforcement]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Law_Enforcement_CT_Law_Enforcement_Agency] FOREIGN KEY([Law_Enforcement_Agency_ID])
REFERENCES [dbo].[CT_Law_Enforcement_Agency] ([ID])
GO
ALTER TABLE [dbo].[Asset_Law_Enforcement] CHECK CONSTRAINT [FK_Asset_Law_Enforcement_CT_Law_Enforcement_Agency]
GO
