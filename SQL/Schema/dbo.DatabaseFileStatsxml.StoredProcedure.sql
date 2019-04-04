IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseFileStatsxml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DatabaseFileStatsxml]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Database File Stats.Added 10pct to reserved allocation to estimate Backup file(Data +log) size
--======================================
CREATE PROCEDURE [dbo].[DatabaseFileStatsxml]
	 @Databases varchar(255)
	,@ResultsXML xml Output
AS
/*
	DECLARE @Databases varchar(255) =  'Transactor_Live,Calculators,Product,STAGINGTABLES'
	,@ResultsXML xml 
	 
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


	SET @ResultsXML = 
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

	SET  @ResultsXML = (SELECT @ResultsXML FOR XML PATH('ResultSets'), TYPE)
END


GO

