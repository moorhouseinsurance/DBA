USE [DBA]
GO
/****** Object:  Table [dbo].[BlockedProcess]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BlockedProcess](
	[BlockedProcessID] [bigint] IDENTITY(1,1) NOT NULL,
	[PolledDateTime] [datetime] NULL,
	[PDBID] [smallint] NULL,
	[PSPID] [smallint] NULL,
	[PName] [sysname] NULL,
	[PType] [nvarchar](60) NULL,
	[Phostname] [nchar](128) NULL,
	[PProgram] [nchar](128) NULL,
	[Pcmd] [nchar](16) NULL,
	[PLoginName] [nchar](128) NULL,
	[PLoginTime] [datetime] NULL,
	[PLastBatch] [datetime] NULL,
	[PScript] [varchar](500) NULL,
	[PWaitTime] [bigint] NULL,
	[PLastWaitType] [nchar](32) NULL,
	[PWaitResource] [nchar](256) NULL,
	[BSPID] [smallint] NULL,
	[BName] [sysname] NULL,
	[BType] [nvarchar](60) NULL,
	[Bhostname] [nchar](128) NULL,
	[BProgram] [nchar](128) NULL,
	[Bcmd] [nchar](16) NULL,
	[BLoginName] [nchar](128) NULL,
	[BLoginTime] [datetime] NULL,
	[BLastBatch] [datetime] NULL,
	[HeadBlocker] [bit] NULL,
	[BScript] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[BlockedProcessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
