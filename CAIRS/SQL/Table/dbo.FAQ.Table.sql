USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[FAQ]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FAQ](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FAQ_Category_ID] [int] NOT NULL,
	[Question] [varchar](max) NOT NULL,
	[Answer] [varchar](max) NULL,
	[Description] [varchar](1000) NULL,
	[Is_Active] [bit] NOT NULL,
	[Sort_Order] [int] NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
 CONSTRAINT [PK__FAQ__3214EC274C77BCB7] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FAQ]  WITH CHECK ADD  CONSTRAINT [FK_FAQ_FAQ_Category] FOREIGN KEY([FAQ_Category_ID])
REFERENCES [dbo].[FAQ_Category] ([ID])
GO
ALTER TABLE [dbo].[FAQ] CHECK CONSTRAINT [FK_FAQ_FAQ_Category]
GO
