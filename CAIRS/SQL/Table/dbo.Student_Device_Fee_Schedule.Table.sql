USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Student_Device_Fee_Schedule]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Student_Device_Fee_Schedule](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Asset_Base_Type_ID] [int] NOT NULL,
	[Asset_Disposition_ID] [int] NOT NULL,
	[Fee_Amount_Without_Coverage] [float] NOT NULL,
	[Fee_Amount_With_Coverage] [float] NOT NULL,
	[Date_Start] [date] NOT NULL,
	[Date_End] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Student_Device_Fee_Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Student_Device_Fee_Schedule_CT_Asset_Base_Type] FOREIGN KEY([Asset_Base_Type_ID])
REFERENCES [dbo].[CT_Asset_Base_Type] ([ID])
GO
ALTER TABLE [dbo].[Student_Device_Fee_Schedule] CHECK CONSTRAINT [FK_Student_Device_Fee_Schedule_CT_Asset_Base_Type]
GO
ALTER TABLE [dbo].[Student_Device_Fee_Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Student_Device_Fee_Schedule_CT_Asset_Disposition] FOREIGN KEY([Asset_Disposition_ID])
REFERENCES [dbo].[CT_Asset_Disposition] ([ID])
GO
ALTER TABLE [dbo].[Student_Device_Fee_Schedule] CHECK CONSTRAINT [FK_Student_Device_Fee_Schedule_CT_Asset_Disposition]
GO
