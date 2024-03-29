USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Attachment]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Attachment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_Student_Transaction_ID] [int] NULL,
	[Asset_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NULL,
	[Asset_Tamper_ID] [int] NULL,
	[Attachment_Type_ID] [int] NULL,
	[File_Type_ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
 CONSTRAINT [PK__Asset_At__3214EC274EFE4C80] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_Asset_Attachment_AssetID_FileTypeID_Name] UNIQUE NONCLUSTERED 
(
	[Asset_ID] ASC,
	[File_Type_ID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Attachment_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Attachment] CHECK CONSTRAINT [FK_Asset_Attachment_Asset]
GO
ALTER TABLE [dbo].[Asset_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Attachment_Asset_Student_Transaction] FOREIGN KEY([Asset_Student_Transaction_ID])
REFERENCES [dbo].[Asset_Student_Transaction] ([ID])
GO
ALTER TABLE [dbo].[Asset_Attachment] CHECK CONSTRAINT [FK_Asset_Attachment_Asset_Student_Transaction]
GO
ALTER TABLE [dbo].[Asset_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Attachment_Asset_Tamper] FOREIGN KEY([Asset_Tamper_ID])
REFERENCES [dbo].[Asset_Tamper] ([ID])
GO
ALTER TABLE [dbo].[Asset_Attachment] CHECK CONSTRAINT [FK_Asset_Attachment_Asset_Tamper]
GO
ALTER TABLE [dbo].[Asset_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Attachment_CT_Attachment_Type] FOREIGN KEY([Attachment_Type_ID])
REFERENCES [dbo].[CT_Attachment_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Attachment] CHECK CONSTRAINT [FK_Asset_Attachment_CT_Attachment_Type]
GO
ALTER TABLE [dbo].[Asset_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Attachment_CT_File_Type] FOREIGN KEY([File_Type_ID])
REFERENCES [dbo].[CT_File_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Attachment] CHECK CONSTRAINT [FK_Asset_Attachment_CT_File_Type]
GO
