USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Repair]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Repair](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Is_Leased] [bit] NOT NULL,
	[Repair_Type_ID] [int] NOT NULL,
	[Comment] [varchar](max) NULL,
	[Date_Sent] [date] NULL,
	[Date_Received] [date] NULL,
	[Received_By_Emp_ID] [varchar](11) NULL,
	[Received_Disposition_ID] [int] NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
 CONSTRAINT [PK__Asset_Re__3214EC2783580B64] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Repair]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Repair_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Repair] CHECK CONSTRAINT [FK_Asset_Repair_Asset]
GO
ALTER TABLE [dbo].[Asset_Repair]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Repair_CT_Asset_Disposition] FOREIGN KEY([Received_Disposition_ID])
REFERENCES [dbo].[CT_Asset_Disposition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Repair] CHECK CONSTRAINT [FK_Asset_Repair_CT_Asset_Disposition]
GO
ALTER TABLE [dbo].[Asset_Repair]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Repair_CT_Repair_Type] FOREIGN KEY([Repair_Type_ID])
REFERENCES [dbo].[CT_Repair_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Repair] CHECK CONSTRAINT [FK_Asset_Repair_CT_Repair_Type]
GO
