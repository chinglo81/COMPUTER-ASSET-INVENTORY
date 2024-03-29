USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Business_Rule_Detail]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Business_Rule_Detail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Business_Rule_ID] [int] NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_Business_Rule_Detail_BusinessRuleId_Code] UNIQUE NONCLUSTERED 
(
	[Business_Rule_ID] ASC,
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Business_Rule_Detail]  WITH CHECK ADD  CONSTRAINT [FK_Business_Rule_Detail_Business_Rule] FOREIGN KEY([Business_Rule_ID])
REFERENCES [dbo].[Business_Rule] ([ID])
GO
ALTER TABLE [dbo].[Business_Rule_Detail] CHECK CONSTRAINT [FK_Business_Rule_Detail_Business_Rule]
GO
