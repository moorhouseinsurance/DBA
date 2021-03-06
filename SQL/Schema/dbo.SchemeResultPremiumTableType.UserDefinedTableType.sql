USE [DBA]
GO
/****** Object:  UserDefinedTableType [dbo].[SchemeResultPremiumTableType]    Script Date: 29/01/2020 10:46:58 ******/
CREATE TYPE [dbo].[SchemeResultPremiumTableType] AS TABLE(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](20) NULL,
	[Value] [money] NULL,
	[PartnerCommission] [money] NULL,
	[AgentCommission] [money] NULL,
	[SubAgentCommission] [money] NULL
)
GO
