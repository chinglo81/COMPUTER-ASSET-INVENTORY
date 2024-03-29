USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Student_Notification]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Student_Notification](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_Student_Transaction_ID] [int] NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NOT NULL,
	[Notification_Type_ID] [int] NOT NULL,
	[Sent_To] [varchar](max) NULL,
	[Date_Sent] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Student_Notification]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Notification_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Notification] CHECK CONSTRAINT [FK_Asset_Student_Notification_Asset]
GO
ALTER TABLE [dbo].[Asset_Student_Notification]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Notification_Asset_Student_Transaction] FOREIGN KEY([Asset_Student_Transaction_ID])
REFERENCES [dbo].[Asset_Student_Transaction] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Notification] CHECK CONSTRAINT [FK_Asset_Student_Notification_Asset_Student_Transaction]
GO
ALTER TABLE [dbo].[Asset_Student_Notification]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Notification_CT_Notification_Type] FOREIGN KEY([Notification_Type_ID])
REFERENCES [dbo].[CT_Notification_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Notification] CHECK CONSTRAINT [FK_Asset_Student_Notification_CT_Notification_Type]
GO
