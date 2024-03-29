USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Reports]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reports](
	[ID] [int] NOT NULL,
	[Report_Code] [varchar](100) NOT NULL,
	[Report_Name] [varchar](100) NOT NULL,
	[Report_Display_Name] [varchar](100) NOT NULL,
	[Report_Folder] [varchar](100) NOT NULL,
	[Report_Description] [varchar](max) NULL,
	[Is_Active] [bit] NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
 CONSTRAINT [PK__Reports__3214EC271314A9F9] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Reports]  WITH CHECK ADD  CONSTRAINT [FK_Reports_Reports] FOREIGN KEY([ID])
REFERENCES [dbo].[Reports] ([ID])
GO
ALTER TABLE [dbo].[Reports] CHECK CONSTRAINT [FK_Reports_Reports]
GO
