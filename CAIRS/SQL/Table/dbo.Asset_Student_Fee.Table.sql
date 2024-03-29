USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Student_Fee]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Student_Fee](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Student_Device_Coverage_ID] [int] NULL,
	[Asset_Student_Transaction_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Asset_Base_Type_ID] [int] NOT NULL,
	[Asset_Type_ID] [int] NOT NULL,
	[Asset_Disposition_ID] [int] NOT NULL,
	[Asset_Disposition_Desc] [varchar](100) NOT NULL,
	[Is_Police_Report_Provided] [bit] NOT NULL,
	[Owed_Amount] [float] NULL,
	[Date_Processed_School_Msg] [datetime] NULL,
	[Date_Processed_Fee] [datetime] NULL,
	[Is_Student_Active_When_Processed_Fee] [bit] NULL,
	[Comment] [varchar](max) NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
	[Is_Active] [bit] NULL,
	[Deactivated_Reason] [varchar](1000) NULL,
	[Deactivated_Date] [datetime] NULL,
	[Deactivated_Emp_ID] [varchar](11) NULL,
 CONSTRAINT [PK__Asset_St__3214EC276F7C72A3] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_Asset]
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_Asset_Student_Transaction] FOREIGN KEY([Asset_Student_Transaction_ID])
REFERENCES [dbo].[Asset_Student_Transaction] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_Asset_Student_Transaction]
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Base_Type] FOREIGN KEY([Asset_Base_Type_ID])
REFERENCES [dbo].[CT_Asset_Base_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Base_Type]
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Disposition] FOREIGN KEY([Asset_Disposition_ID])
REFERENCES [dbo].[CT_Asset_Disposition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Disposition]
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Type] FOREIGN KEY([Asset_Type_ID])
REFERENCES [dbo].[CT_Asset_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Type]
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Type1] FOREIGN KEY([Asset_Type_ID])
REFERENCES [dbo].[CT_Asset_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_CT_Asset_Type1]
GO
ALTER TABLE [dbo].[Asset_Student_Fee]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Fee_Student_Device_Coverage] FOREIGN KEY([Student_Device_Coverage_ID])
REFERENCES [dbo].[Student_Device_Coverage] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Fee] CHECK CONSTRAINT [FK_Asset_Student_Fee_Student_Device_Coverage]
GO
