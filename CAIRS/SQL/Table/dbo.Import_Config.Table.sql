USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Import_Config]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Import_Config](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Device_Fee_Type_ID] [int] NULL,
	[School_Num] [varchar](3) NOT NULL,
	[School_Name] [varchar](25) NOT NULL,
	[File_Path] [varchar](1000) NOT NULL,
	[Date_File_Last_Modified] [datetime] NULL,
	[Date_Last_Import] [datetime] NULL,
	[Comment] [varchar](max) NULL,
	[Is_Active] [bit] NOT NULL,
	[Last_Import_Count_Total] [int] NULL,
	[Last_Import_Count_Error] [int] NULL,
	[Last_Import_Count_Success] [int] NULL,
	[Last_Import_Count_Not_Processed] [int] NULL,
	[Last_Import_Status] [varchar](max) NULL,
 CONSTRAINT [PK__Student___3214EC27DC1FB298] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
