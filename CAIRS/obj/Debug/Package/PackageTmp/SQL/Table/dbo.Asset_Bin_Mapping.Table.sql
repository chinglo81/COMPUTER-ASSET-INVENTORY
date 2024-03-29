USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Bin_Mapping]    Script Date: 2/3/2017 10:33:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Bin_Mapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Bin_ID] [int] NULL,
	[Asset_ID] [int] NOT NULL,
	[Date_Added] [datetime] NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
