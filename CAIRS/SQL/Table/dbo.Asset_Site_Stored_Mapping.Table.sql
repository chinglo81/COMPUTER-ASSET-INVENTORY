USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Site_Stored_Mapping]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Site_Stored_Mapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Asset_Site_ID] [int] NOT NULL,
	[Stored_Site_ID] [int] NULL,
	[Emp_ID] [varchar](11) NOT NULL,
	[Date_Modified] [datetime] NOT NULL,
 CONSTRAINT [PK__Asset_Si__3214EC275A875FAF] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_Asset_Site_Stored_Mapping_Asset_ID] UNIQUE NONCLUSTERED 
(
	[Asset_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Site_Stored_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Site_Stored_Mapping_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Site_Stored_Mapping] CHECK CONSTRAINT [FK_Asset_Site_Stored_Mapping_Asset]
GO
