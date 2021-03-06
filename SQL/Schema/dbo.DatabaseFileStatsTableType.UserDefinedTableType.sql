USE [DBA]
GO
/****** Object:  UserDefinedTableType [dbo].[DatabaseFileStatsTableType]    Script Date: 29/01/2020 10:46:58 ******/
CREATE TYPE [dbo].[DatabaseFileStatsTableType] AS TABLE(
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
)
GO
