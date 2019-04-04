IF  EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'DatabaseFileStatsTableType' AND ss.name = N'dbo')
DROP TYPE [dbo].[DatabaseFileStatsTableType]
GO

GO
CREATE TYPE [dbo].[DatabaseFileStatsTableType] AS TABLE(
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
)
GO

