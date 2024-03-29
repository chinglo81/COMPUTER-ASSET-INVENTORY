USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Tag_ID] [varchar](100) NOT NULL,
	[Asset_Disposition_ID] [int] NOT NULL,
	[Asset_Condition_ID] [int] NOT NULL,
	[Asset_Type_ID] [int] NOT NULL,
	[Asset_Assignment_Type_ID] [int] NOT NULL,
	[Serial_Number] [varchar](100) NULL,
	[Date_Purchased] [date] NULL,
	[Leased_Term_Days] [int] NULL,
	[Warranty_Term_Days] [int] NULL,
	[Is_Leased] [bit] NOT NULL,
	[Is_Active] [bit] NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NULL,
 CONSTRAINT [PK__Asset__3214EC279B11E74D] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_Serial_Number] UNIQUE NONCLUSTERED 
(
	[Serial_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset]  WITH CHECK ADD  CONSTRAINT [FK_Asset_CT_Asset_Assignment_Type] FOREIGN KEY([Asset_Assignment_Type_ID])
REFERENCES [dbo].[CT_Asset_Assignment_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset] CHECK CONSTRAINT [FK_Asset_CT_Asset_Assignment_Type]
GO
ALTER TABLE [dbo].[Asset]  WITH CHECK ADD  CONSTRAINT [FK_Asset_CT_Asset_Condition] FOREIGN KEY([Asset_Condition_ID])
REFERENCES [dbo].[CT_Asset_Condition] ([ID])
GO
ALTER TABLE [dbo].[Asset] CHECK CONSTRAINT [FK_Asset_CT_Asset_Condition]
GO
ALTER TABLE [dbo].[Asset]  WITH CHECK ADD  CONSTRAINT [FK_Asset_CT_Asset_Disposition] FOREIGN KEY([Asset_Disposition_ID])
REFERENCES [dbo].[CT_Asset_Disposition] ([ID])
GO
ALTER TABLE [dbo].[Asset] CHECK CONSTRAINT [FK_Asset_CT_Asset_Disposition]
GO
ALTER TABLE [dbo].[Asset]  WITH CHECK ADD  CONSTRAINT [FK_Asset_CT_Asset_Type] FOREIGN KEY([Asset_Type_ID])
REFERENCES [dbo].[CT_Asset_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset] CHECK CONSTRAINT [FK_Asset_CT_Asset_Type]
GO
