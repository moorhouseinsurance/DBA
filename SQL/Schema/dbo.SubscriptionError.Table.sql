USE [DBA]
GO
/****** Object:  Table [dbo].[SubscriptionError]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionError](
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](425) NULL,
	[Description] [nvarchar](512) NULL,
	[LastStatus] [nvarchar](260) NULL,
	[LastRunTime] [datetime] NULL,
	[DeliveryExtension] [nvarchar](260) NULL
) ON [PRIMARY]

GO
