USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Temp_Detail]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Temp_Detail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_Temp_Header_ID] [int] NOT NULL,
	[Tag_ID] [varchar](100) NOT NULL,
	[Asset_Disposition_ID] [int] NOT NULL,
	[Asset_Condition_ID] [int] NOT NULL,
	[Asset_Type_ID] [int] NOT NULL,
	[Asset_Assignment_Type_ID] [int] NOT NULL,
	[Bin_ID] [int] NULL,
	[Serial_Number] [varchar](100) NULL,
	[Date_Purchased] [date] NULL,
	[Is_Leased] [bit] NULL,
	[Leased_Term_Days] [int] NULL,
	[Warranty_Term_Days] [int] NULL,
	[Date_Added] [datetime] NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
 CONSTRAINT [PK__Asset_Te__3214EC27279E6142] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
