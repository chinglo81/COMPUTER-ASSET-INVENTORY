USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[FAQ_Comment]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FAQ_Comment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FAQ_ID] [int] NOT NULL,
	[Comment] [varchar](max) NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FAQ_Comment]  WITH CHECK ADD  CONSTRAINT [FK_FAQ_Comment_FAQ] FOREIGN KEY([FAQ_ID])
REFERENCES [dbo].[FAQ] ([ID])
GO
ALTER TABLE [dbo].[FAQ_Comment] CHECK CONSTRAINT [FK_FAQ_Comment_FAQ]
GO
