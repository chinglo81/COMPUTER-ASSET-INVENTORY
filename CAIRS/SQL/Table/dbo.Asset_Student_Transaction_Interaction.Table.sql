USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Student_Transaction_Interaction]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Student_Transaction_Interaction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_Student_Transaction_ID] [int] NOT NULL,
	[Interaction_Type_ID] [int] NOT NULL,
	[Comment] [varchar](1000) NULL,
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
ALTER TABLE [dbo].[Asset_Student_Transaction_Interaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_Interaction_Asset_Student_Transaction] FOREIGN KEY([Asset_Student_Transaction_ID])
REFERENCES [dbo].[Asset_Student_Transaction] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction_Interaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_Interaction_Asset_Student_Transaction]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction_Interaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_Interaction_CT_Interaction_Type] FOREIGN KEY([Interaction_Type_ID])
REFERENCES [dbo].[CT_Interaction_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction_Interaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_Interaction_CT_Interaction_Type]
GO
