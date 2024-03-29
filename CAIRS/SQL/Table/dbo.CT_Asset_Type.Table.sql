USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[CT_Asset_Type]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_Asset_Type](
	[ID] [int] NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Asset_Base_Type_ID] [int] NOT NULL,
	[Vendor_ID] [int] NULL,
	[Is_Vendor_Req] [bit] NOT NULL,
	[Is_Serial_Req] [bit] NOT NULL,
	[Is_Active] [bit] NOT NULL,
 CONSTRAINT [PK__CT_Asset__3214EC278E75E123] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_CT_Asset_Type_Code] UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[CT_Asset_Type]  WITH CHECK ADD  CONSTRAINT [FK_CT_Asset_Type_CT_Asset_Base_Type] FOREIGN KEY([Asset_Base_Type_ID])
REFERENCES [dbo].[CT_Asset_Base_Type] ([ID])
GO
ALTER TABLE [dbo].[CT_Asset_Type] CHECK CONSTRAINT [FK_CT_Asset_Type_CT_Asset_Base_Type]
GO
ALTER TABLE [dbo].[CT_Asset_Type]  WITH CHECK ADD  CONSTRAINT [FK_CT_Asset_Type_CT_Vendor] FOREIGN KEY([Vendor_ID])
REFERENCES [dbo].[CT_Vendor] ([ID])
GO
ALTER TABLE [dbo].[CT_Asset_Type] CHECK CONSTRAINT [FK_CT_Asset_Type_CT_Vendor]
GO
