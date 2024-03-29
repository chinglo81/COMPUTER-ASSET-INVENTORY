USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[CT_Fee_Type_Mapping]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_Fee_Type_Mapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_Disposition_ID] [int] NOT NULL,
	[Asset_Base_Type_ID] [int] NOT NULL,
	[Fee_Code] [varchar](2) NULL,
	[Fee_Type_Desc] [varchar](50) NULL,
 CONSTRAINT [PK_CT_Fee_Type_Mapping] PRIMARY KEY CLUSTERED 
(
	[Asset_Base_Type_ID] ASC,
	[Asset_Disposition_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
