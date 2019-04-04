IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseFileStatsTable]') AND type in (N'U'))
DROP TABLE [dbo].[DatabaseFileStatsTable]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DatabaseFileStatsTable](
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LogicalFileName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Type] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileSizeMb] [int] NULL,
	[Drive] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DriveName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DriveSizeMB] [int] NULL,
	[DriveFreeSpaceMB] [int] NULL,
	[BackupEstimatedSizeMB] [int] NULL
) ON [PRIMARY]

GO

