USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Audit_Log]    Script Date: 2/3/2017 10:33:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Audit_Log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Table_Name] [varchar](100) NOT NULL,
	[Primary_Key_ID] [int] NOT NULL,
	[Column_Name] [varchar](100) NOT NULL,
	[Column_Name_Desc] [varchar](100) NOT NULL,
	[Old_Value] [varchar](1000) NULL,
	[Old_Value_Desc] [varchar](1000) NULL,
	[New_Value] [varchar](1000) NULL,
	[New_Value_Desc] [varchar](1000) NULL,
	[Emp_ID] [varchar](11) NOT NULL,
	[Date_Modified] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
