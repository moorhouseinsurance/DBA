CREATE TABLE DatabaseFileStatsTable 
	(
		 [DatabaseName] varchar(100)
		,[LogicalFileName] varchar(100)
		,[FileName] varchar(100)
		,[Type] varchar(10)
		,[FileSizeMb] int
		,[Drive]  varchar(3)
		,[DriveName] varchar(100)
		,[DriveSizeMB] int
		,[DriveFreeSpaceMB] int
		,[BackupEstimatedSizeMB] int
	)
	go

CREATE TYPE [dbo].[DatabaseFileStatsTableType] AS TABLE
	(
		 [DatabaseName] varchar(100)
		,[LogicalFileName] varchar(100)
		,[FileName] varchar(100)
		,[Type] varchar(10)
		,[FileSizeMb] int
		,[Drive]  varchar(3)
		,[DriveName] varchar(100)
		,[DriveSizeMB] int
		,[DriveFreeSpaceMB] int
		,[BackupEstimatedSizeMB] int
	)
GO


--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Database File Stats.Added 10pct to reserved allocation to estimate Backup file(Data +log) size
--======================================
alter PROCEDURE [dbo].[DatabaseFileStatsxml]
	 @Databases varchar(255)
	,@ResultsXML varchar(8000) Output
AS
/*
	DECLARE @Databases varchar(255) = 'Transactor_Live,Calculators,Product,STAGINGTABLES'
	,@ResultsXML varchar(8000)
	 
	exec [dbo].[DatabaseFileStatsxml] @Databases ,@ResultsXML Output
	SELECT @ResultsXML

*/
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @DatabaseFiles TABLE ( [DatabaseName] varchar(20))
	INSERT INTO @DatabaseFiles([DatabaseName])
	SELECT * FROM [dbo].[tvfSplitStringByDelimiter](@Databases ,',')

	
	DECLARE @SQL varchar(1000) = ' USE [?] SELECT DB_NAME() AS [DatabaseName] ,SUM([Total_Pages])*8.0 AS [BackupEstimatedSizeKB] FROM [sys].[Allocation_Units]' 
	DECLARE @Backup Table ([DatabaseName] varchar(100) ,[BackupEstimatedSizeKB] int)

	INSERT INTO @Backup ([DatabaseName] ,[BackupEstimatedSizeKB])
	EXEC sp_MSforeachdb @SQL

	DECLARE @ResultsXML1 xml
	SET @ResultsXML1 = 
	(
		SELECT 
			 DB_NAME([F].[Database_ID]) AS [DatabaseName]
			,[F].[Name] AS [LogicalFileName]
			,[F].[Physical_Name] AS [FileName]
			,[F].[Type_Desc] AS [Type]
			,([F].[Size] * 8) / 1024 AS [FileSizeMb]
			,[VS].[Volume_Mount_Point] AS [Drive]
			,[VS].[Logical_Volume_Name] AS [DriveName]
			,[VS].[Total_bytes]/1024/1024 AS [DriveSizeMB]
			,[VS].[Available_bytes]/1024/1024 AS [DriveFreeSpaceMB]
			,CEILING([B].[BackupEstimatedSizeKB]*1.1/1024 )AS [BackupEstimatedSizeMB]
		FROM 
			@DatabaseFiles AS [D]
			JOIN [sys].[master_files] AS [F] ON [D].[DatabaseName] = DB_NAME([F].[database_id]) 
			CROSS APPLY [sys].[dm_os_volume_stats]([F].[database_id], [F].[file_id]) AS [VS]
			JOIN @Backup AS [B] ON DB_NAME([F].[database_id]) = [B].[DatabaseName]
		ORDER BY [B].[DatabaseName]
		FOR XML PATH('ResultSet'), TYPE
	)

	SET  @ResultsXML = CONVERT(VARCHAR(8000),(SELECT @ResultsXML1 FOR XML PATH('ResultSets'), TYPE))
END

GO

--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Database File Stats.Added 10pct to reserved allocation to estimate Backup file(Data +log) size
--======================================
ALTER PROCEDURE [dbo].[DatabaseFileStats]
	 @Databases varchar(255)
AS
/*
	DECLARE @Databases varchar(255) =  'tempdb'-- 'Transactor_Live,Calculators,Product,STAGINGTABLES' 
	exec [dbo].[DatabaseFileStats] @Databases 

*/
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @ResultsXML varchar(8000)
	exec [dbo].[DatabaseFileStatsxml] @Databases ,@ResultsXML Output

	DECLARE  @handle INT  ,@PrepareXmlStatus INT  
	EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @ResultsXML  
	SELECT  * FROM  OPENXML(@handle, '/ResultSets/ResultSet', 2) WITH [DatabaseFileStatsTable]
	
END


DECLARE @LocalDatabaseFileStatsTable  [dbo].[DatabaseFileStatsTableType]
DECLARE @RemoteDatabaseFileStatsTable  [dbo].[DatabaseFileStatsTableType]

DECLARE @Databases varchar(255) =  'Transactor_Live,Calculators,Product,STAGINGTABLES' 

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

SELECT  * FROM  @LocalDatabaseFileStatsTable
SELECT  * FROM  @RemoteDatabaseFileStatsTable


SELECT
	 [R].[DatabaseName]
	,[R].[FileName]
	,[R].[FileSizeMB] - ISNULL([L].[FileSizeMB],0) AS [FileSizeRequiredMB]
FROM  
	@RemoteDatabaseFileStatsTable AS [R]
	LEFT JOIN @LocalDatabaseFileStatsTable AS [L] ON [L].[LogicalFileName] = [R].[LogicalFileName]
ORDER BY
	 [DatabaseName]
	,[R].[FileName]



--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Filesize stats for deciding to backup and restore.
--======================================
alter PROCEDURE [dbo].[DatabaseBackupReport]
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