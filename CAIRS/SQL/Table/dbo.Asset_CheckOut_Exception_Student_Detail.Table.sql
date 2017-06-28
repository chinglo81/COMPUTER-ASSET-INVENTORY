USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_CheckOut_Exception_Student_Detail]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_CheckOut_Exception_Student_Detail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_CheckOut_Exception_Student_Header_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_CheckOut_Exception_Student_Detail]  WITH CHECK ADD  CONSTRAINT [FK_Asset_CheckOut_Exception_Student_Detail_Asset_CheckOut_Exception_Student_Header] FOREIGN KEY([Asset_CheckOut_Exception_Student_Header_ID])
REFERENCES [dbo].[Asset_CheckOut_Exception_Student_Header] ([ID])
GO
ALTER TABLE [dbo].[Asset_CheckOut_Exception_Student_Detail] CHECK CONSTRAINT [FK_Asset_CheckOut_Exception_Student_Detail_Asset_CheckOut_Exception_Student_Header]
GO
