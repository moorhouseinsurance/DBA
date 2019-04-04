IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseBackupReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DatabaseBackupReport]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Filesize stats for deciding to backup and restore.
--======================================
CREATE PROCEDURE [dbo].[DatabaseBackupReport]
	 @Databases varchar(255) =  'Transactor_Live,Calculators,Product,Dialler,MArketing'     --comma delimited database list
	,@BackupDrive char(3) = 'L:\'															--Drive where backup file is located
	,@DiskspacepctFreeSpaceThreshold numeric (10,2) = 10								    --Pct disk space to leave free after restore
	,@OverWrite bit = 'true'																--OverWrite existing database, False = creating a copy.
AS
/*
	DECLARE @Databases varchar(255) =  'Transactor_Live,Calculators,Product,Dialler,MArketing' 
	DECLARE @BackupDrive char(3) = 'L:\'
	DECLARE @DiskspacepctFreeSpaceThreshold numeric (10,2) = 10
	DECLARE @OverWrite bit = --'true'
	exec [dbo].[DatabaseBackupReport] -- @Databases ,@BackupDrive ,@DiskspacepctFreeSpaceThreshold , @OverWrite

	exec [dbo].[DatabaseBackupReport] @OverWrite = 'False'

*/
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @LocalDatabaseFileStatsTable  [dbo].[DatabaseFileStatsTableType]
	DECLARE @RemoteDatabaseFileStatsTable  [dbo].[DatabaseFileStatsTableType]


	DECLARE @localResultsXML xml ,@RemoteResultsXML varchar(8000)
	exec  [MHGSQL01\TGSLTest].[DBA].[dbo].[DatabaseFileStatsxml] @Databases ,@localResultsXML Output
	exec  [MHGSQL01\TGSL].[DBA].[dbo].[DatabaseFileStatsxml] @Databases ,@RemoteResultsXML Output


	DECLARE @handle INT 
 
	EXEC sp_xml_preparedocument @handle OUTPUT, @localResultsXML  
	INSERT INTO @LocalDatabaseFileStatsTable
	SELECT  * FROM  OPENXML(@handle, '/ResultSets/ResultSet', 2) WITH [DatabaseFileStatsTable]

	EXEC sp_xml_preparedocument @handle OUTPUT, @RemoteResultsXML  
	INSERT INTO @RemoteDatabaseFileStatsTable
	SELECT  * FROM  OPENXML(@handle, '/ResultSets/ResultSet', 2) WITH [DatabaseFileStatsTable]

	;WITH [S] AS
	(
		SELECT
			 [R].[DatabaseName]
			,[R].[FileName]
			,[L].[DriveSizeMB]
			,[L].[DriveFreeSpaceMB]
			,CASE WHEN @OverWrite = 'true' THEN [R].[FileSizeMB] - ISNULL([L].[FileSizeMB],0) ELSE [R].[FileSizeMB] END AS [FileSizeRequiredMB]
			,CASE WHEN [L].[Drive] = @BackupDrive THEN [R].[BackupEstimatedSizeMB] ELSE 0 END AS [BackupEstimatedSizeMB]
		FROM  
			@RemoteDatabaseFileStatsTable AS [R]
			LEFT JOIN @LocalDatabaseFileStatsTable AS [L] ON [L].[LogicalFileName] = [R].[LogicalFileName]
	)
	,[S1] AS
	(
		SELECT
			*
			,[DriveFreeSpaceMB] - [FileSizeRequiredMB] - [BackupEstimatedSizeMB] AS [EstFreeSpace]
		FROM  
			[S]
	)

	SELECT
		*
		,CAST((CAST([EstFreeSpace] AS numeric(12,2)) /CAST([DriveSizeMB] AS numeric(12,2)))*100 AS numeric(4,2)) AS [pctFreeSpace]
		,@DiskspacepctFreeSpaceThreshold AS [DiskspacepctFreeSpaceThreshold]
		,CASE WHEN CAST((CAST([EstFreeSpace] AS numeric(12,2)) /CAST([DriveSizeMB] AS numeric(12,2)))*100 AS numeric(4,2)) < @DiskspacepctFreeSpaceThreshold THEN 'No' ELSE 'Yes' End
	FROM  
		[S1]

END
GO

