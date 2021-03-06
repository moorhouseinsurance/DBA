USE [DBA]
GO
/****** Object:  Table [dbo].[DatabaseFileStatsTable]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DatabaseFileStatsTable](
	[DatabaseName] [varchar](100) NULL,
	[LogicalFileName] [varchar](100) NULL,
	[FileName] [varchar](100) NULL,
	[Type] [varchar](10) NULL,
	[FileSizeMb] [int] NULL,
	[Drive] [varchar](3) NULL,
	[DriveName] [varchar](100) NULL,
	[DriveSizeMB] [int] NULL,
	[DriveFreeSpaceMB] [int] NULL,
	[BackupEstimatedSizeMB] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
