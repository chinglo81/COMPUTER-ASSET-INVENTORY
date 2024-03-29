USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[App_User_Preference]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[App_User_Preference](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[App_Preference_Type_ID] [int] NOT NULL,
	[Emp_ID] [varchar](11) NULL,
	[Preference_Value] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[App_User_Preference]  WITH CHECK ADD  CONSTRAINT [FK_App_User_Preference_App_Preference_Type] FOREIGN KEY([App_Preference_Type_ID])
REFERENCES [dbo].[App_Preference_Type] ([ID])
GO
ALTER TABLE [dbo].[App_User_Preference] CHECK CONSTRAINT [FK_App_User_Preference_App_Preference_Type]
GO
