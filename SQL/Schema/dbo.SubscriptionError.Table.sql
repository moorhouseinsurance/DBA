IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SubscriptionError]') AND type in (N'U'))
DROP TABLE [dbo].[SubscriptionError]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionError](
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](425) COLLATE Latin1_General_CI_AS_KS_WS NULL,
	[Description] [nvarchar](512) COLLATE Latin1_General_CI_AS_KS_WS NULL,
	[LastStatus] [nvarchar](260) COLLATE Latin1_General_CI_AS_KS_WS NULL,
	[LastRunTime] [datetime] NULL,
	[DeliveryExtension] [nvarchar](260) COLLATE Latin1_General_CI_AS_KS_WS NULL
) ON [PRIMARY]

GO

