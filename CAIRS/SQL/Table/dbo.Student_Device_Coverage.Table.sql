USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Student_Device_Coverage]    Script Date: 10/5/2017 11:31:17 AM ******/
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
	[Import_Record_History_ID] [int] NULL,
	[Date_Paid] [date] NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NULL,
	[Is_Active] [bit] NULL,
 CONSTRAINT [PK__Student___3214EC27AC2995BE] PRIMARY KEY CLUSTERED 
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
