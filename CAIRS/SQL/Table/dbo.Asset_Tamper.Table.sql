USE [Asset_Tracking]
GO
/****** Object:  Table [dbo].[Asset_Tamper]    Script Date: 10/5/2017 11:31:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Asset_Tamper](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Asset_ID] [int] NOT NULL,
	[Student_ID] [varchar](20) NULL,
	[Student_School_Number] [varchar](3) NULL,
	[Comment] [varchar](max) NULL,
	[Date_Processed] [datetime] NULL,
	[Added_By_Emp_ID] [varchar](11) NOT NULL,
	[Date_Added] [datetime] NOT NULL,
	[Modified_By_Emp_ID] [varchar](11) NULL,
	[Date_Modified] [datetime] NULL,
 CONSTRAINT [PK__Asset_Ta__3214EC27CA9836BC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Asset_Tamper]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Tampered_Asset] FOREIGN KEY([Asset_ID])
REFERENCES [dbo].[Asset] ([ID])
GO
ALTER TABLE [dbo].[Asset_Tamper] CHECK CONSTRAINT [FK_Asset_Tampered_Asset]
GO
