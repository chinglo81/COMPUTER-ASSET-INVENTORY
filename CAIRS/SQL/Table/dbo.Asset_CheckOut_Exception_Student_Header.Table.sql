USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_CheckOut_Exception_Student_Header]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_CheckOut_Exception_Student_Header](
	[ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Asset_Base_Type_ID] [int] NOT NULL,
	[Max_Check_Out_Override] [int] NOT NULL,
	[Is_Active] [bit] NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
 CONSTRAINT [PK__Asset_Ch__3214EC27440A6A22] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_CheckOut_Exception_Student_Header]  WITH CHECK ADD  CONSTRAINT [FK_Asset_CheckOut_Exception_Student_Header_CT_Asset_Base_Type1] FOREIGN KEY([Asset_Base_Type_ID])
REFERENCES [dbo].[CT_Asset_Base_Type] ([ID])
GO
ALTER TABLE [dbo].[Asset_CheckOut_Exception_Student_Header] CHECK CONSTRAINT [FK_Asset_CheckOut_Exception_Student_Header_CT_Asset_Base_Type1]
GO
