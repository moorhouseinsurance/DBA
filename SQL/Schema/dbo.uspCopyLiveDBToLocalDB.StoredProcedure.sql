IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCopyLiveDBToLocalDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspCopyLiveDBToLocalDB]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		01 Apr 2019
--Desc		Copy MHGSQL01\TGSL Instance database (Single data file single log file as per prodec)
--======================================
CREATE PROCEDURE [dbo].[uspCopyLiveDBToLocalDB]
	 @DBName varchar(200)
	,@DBLocalName  varchar(200) = NULL
AS

/*

	DECLARE @DBName varchar(200) = 'Test'
	--DECLARE @DBLocalName varchar(200) = 'Test'
	EXEC [dbo].[uspCopyLiveDBToLocalDB] @DBName 

*/
BEGIN
	IF @@ServerName =  'MHGSQL01\TGSL'
		RETURN 0

	IF @DBLocalName IS NULL
		SET @DBLocalName = @DBName

	DECLARE @Source Nvarchar(200) = ''
	DECLARE @Log Nvarchar(200) = ''
	DECLARE @Data Nvarchar(200) = ''
	DECLARE @LogicalNameData Nvarchar(200) = ''
	DECLARE @LogicalNameLog Nvarchar(200) = ''
	DECLARE @ExistsLocalDB bit

	SET @ExistsLocalDB = (SELECT CASE WHEN COUNT(*) != 0 THEN 1 ELSE 0 END FROM [sys].[Databases] WHERE [Name] = @DBName)

	SELECT  @LogicalNameData = [M].[Name] FROM [MHGSQL01\TGSL].[DBA].[sys].[master_files] AS [M] JOIN [MHGSQL01\TGSL].[DBA].[sys].[Databases] AS [D] ON [M].[Database_ID] = [D].[Database_ID] WHERE [D].[Name] = @DBName AND type_desc= 'ROWS'
	SELECT  @LogicalNameLog = [M].[Name] FROM [MHGSQL01\TGSL].[DBA].[sys].[master_files] AS [M] JOIN [MHGSQL01\TGSL].[DBA].[sys].[Databases] AS [D] ON [M].[Database_ID] = [D].[Database_ID] WHERE [D].[Name] = @DBName AND type_desc= 'LOG'

	exec [MHGSQL01\TGSL].[DBA].[dbo].[uspBackupDatabase] @DBName ,@Source out
	SET @log = N'L:\SQL_Logs\TGSLTest\'  + @DBLocalName + '.ldf'
	SET @Data = N'S:\SQL_Data\TGSLTest\' + @DBLocalName + '.mdf'

	IF 	@Source != ''
	BEGIN
		DECLARE @SQL NVARCHAR(2000);

		SET @SQL = 
		CASE WHEN @ExistsLocalDB = 1 THEN N'
			ALTER DATABASE '	+ @DBLocalName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
			RESTORE DATABASE '	+ @DBLocalName + ' FROM  DISK = @Source WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
				MOVE '''	+ @LogicalNameData + ''' TO @Data,
				MOVE '''	+ @LogicalNameLog + ''' TO @log;
			ALTER DATABASE '	+ @LogicalNameLog + ' SET MULTI_USER WITH ROLLBACK IMMEDIATE'	
		ELSE
			N'
			RESTORE DATABASE '	+ @DBLocalName + ' FROM  DISK = @Source WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
				MOVE '''	+ @LogicalNameData + ''' TO @Data,
				MOVE '''	+ @LogicalNameLog + ''' TO @log;'

		END

		PRINT @SQL
		PRINT @sOURCE
		PRINT @DATA
		PRINT @LOG
		EXEC sp_executesql @SQL ,N'@Source varchar(200) ,@Data varchar(200) ,@Log varchar(200)' ,@Source ,@Data ,@Log

		IF @DBName = 'Transactor_Live'
		BEGIN
			SET @SQL = 'use ' + @DBLocalName + ';' 
			+ 'ALTER USER [TGSLUser] WITH LOGIN = [TGSLUser];'
			+ 'ALTER USER [TgslUserWeb] WITH LOGIN = [TgslUserWeb];'

			EXEC sp_executesql @SQL
		END
	END
END

GO

