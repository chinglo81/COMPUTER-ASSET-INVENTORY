USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Student_Transaction]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Student_Transaction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Asset_Site_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NOT NULL,
	[Student_School_Number] [varchar](3) NOT NULL,
	[School_Year] [int] NOT NULL,
	[Check_Out_Asset_Condition_ID] [int] NULL,
	[Check_Out_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Check_Out] [datetime] NOT NULL,
	[Check_In_Type_ID] [int] NULL,
	[Check_In_Asset_Condition_ID] [int] NULL,
	[Check_In_By_Emp_ID] [varchar](11) NULL,
	[Date_Check_In] [datetime] NULL,
	[Comment] [varchar](max) NULL,
	[Check_In_Disposition_ID] [int] NULL,
	[Found_Date] [date] NULL,
	[Found_Disposition_ID] [int] NULL,
	[Found_Asset_Condition_ID] [int] NULL,
	[Stu_Responsible_For_Damage] [bit] NULL,
	[Is_Police_Report_Provided] [bit] NULL,
 CONSTRAINT [PK__Asset_St__3214EC2774D5D59E] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_Asset]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Condition] FOREIGN KEY([Found_Asset_Condition_ID])
REFERENCES [dbo].[CT_Asset_Condition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Condition]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Condition_Check_In] FOREIGN KEY([Check_In_Asset_Condition_ID])
REFERENCES [dbo].[CT_Asset_Condition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Condition_Check_In]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Condition_Check_Out] FOREIGN KEY([Check_Out_Asset_Condition_ID])
REFERENCES [dbo].[CT_Asset_Condition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Condition_Check_Out]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Disposition] FOREIGN KEY([Found_Disposition_ID])
REFERENCES [dbo].[CT_Asset_Disposition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Disposition]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Disposition_Check_In] FOREIGN KEY([Check_In_Disposition_ID])
REFERENCES [dbo].[CT_Asset_Disposition] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Asset_Disposition_Check_In]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Check_In_Type] FOREIGN KEY([Check_In_Type_ID])
REFERENCES [dbo].[CT_Check_In_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Check_In_Type]
GO
ALTER TABLE [dbo].[Asset_Student_Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Student_Transaction_CT_Site] FOREIGN KEY([Asset_Site_ID])
REFERENCES [dbo].[CT_Site] ([ID])
GO
ALTER TABLE [dbo].[Asset_Student_Transaction] CHECK CONSTRAINT [FK_Asset_Student_Transaction_CT_Site]
GO
