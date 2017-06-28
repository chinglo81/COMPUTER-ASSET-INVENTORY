USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Student_Device_Coverage]    Script Date: 6/28/2017 10:58:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Student_Device_Coverage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Student_ID] [varchar](20) NOT NULL,
	[Device_Fee_Type_ID] [int] NOT NULL,
	[School_Year] [int] NOT NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NULL,
	[Is_Active] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Unique_Student_Device_Coverage_StudentID_School_Year] UNIQUE NONCLUSTERED 
(
	[Student_ID] ASC,
	[School_Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Student_Device_Coverage]  WITH CHECK ADD  CONSTRAINT [FK_Student_Device_Coverage_CT_Device_Fee_Type] FOREIGN KEY([Device_Fee_Type_ID])
REFERENCES [dbo].[CT_Device_Fee_Type] ([ID])
GO
ALTER TABLE [dbo].[Student_Device_Coverage] CHECK CONSTRAINT [FK_Student_Device_Coverage_CT_Device_Fee_Type]
GO
