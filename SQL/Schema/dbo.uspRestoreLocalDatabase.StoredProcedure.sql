USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspRestoreLocalDatabase]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--======================================
--Author	D. Hostler
--Date		04 Apr 2019
--Desc		Restore MHGSQL01\TGSLTest Instance database (Single data file single log file as per prodec)
--======================================
CREATE PROCEDURE [dbo].[uspRestoreLocalDatabase]
	 @DBName varchar(200)
	,@DBLocalName  varchar(200) = NULL
	,@Source Nvarchar(200)
AS

/*

DECLARE @RC int
DECLARE @DBName varchar(200)
DECLARE @DBLocalName varchar(200)
DECLARE @Source nvarchar(200)

EXECUTE @RC = [dbo].[uspRestoreDatabase] @DBName ,@DBLocalName ,@Source

*/
BEGIN
	SET NOCOUNT ON
	DECLARE @ReturnCode int = 0

	IF @@ServerName =  'MHGSQL01\TGSL'
		RETURN 1

	IF @DBLocalName IS NULL
		SET @DBLocalName = @DBName

	IF 	@Source = ''
		RETURN 2

	BEGIN
		DECLARE @Log Nvarchar(200) = ''
		DECLARE @Data Nvarchar(200) = ''
		DECLARE @LogicalNameData Nvarchar(200) = ''
		DECLARE @LogicalNameLog Nvarchar(200) = ''

		SELECT  @LogicalNameData = [M].[Name] FROM [MHGSQL01\TGSLTest].[DBA].[sys].[master_files] AS [M] JOIN [MHGSQL01\TGSLTest].[DBA].[sys].[Databases] AS [D] ON [M].[Database_ID] = [D].[Database_ID] WHERE [D].[Name] = @DBName AND type_desc= 'ROWS'
		SELECT  @LogicalNameLog = [M].[Name] FROM [MHGSQL01\TGSLTest].[DBA].[sys].[master_files] AS [M] JOIN [MHGSQL01\TGSLTest].[DBA].[sys].[Databases] AS [D] ON [M].[Database_ID] = [D].[Database_ID] WHERE [D].[Name] = @DBName AND type_desc= 'LOG'

		SET @log = N'L:\SQL_Logs\TGSLTest\'  + @DBLocalName + '.ldf'
		SET @Data = N'S:\SQL_Data\TGSLTest\' + @DBLocalName + '.mdf'

		DECLARE @ExistsLocalDB bit
		SET @ExistsLocalDB = (SELECT CASE WHEN COUNT(*) != 0 THEN 1 ELSE 0 END FROM [sys].[Databases] WHERE [Name] = @DBLocalName)

		DECLARE @SQL NVARCHAR(2000);
		SET @SQL = 
		CASE WHEN @ExistsLocalDB = 1 THEN N'
			ALTER DATABASE '	+ @DBLocalName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
			RESTORE DATABASE '	+ @DBLocalName + ' FROM  DISK = @Source WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
				MOVE '''	+ @LogicalNameData + ''' TO @Data,
				MOVE '''	+ @LogicalNameLog + ''' TO @log;
			ALTER DATABASE '	+ @DBLocalName + ' SET MULTI_USER WITH ROLLBACK IMMEDIATE'	
		ELSE
			N'
			RESTORE DATABASE '	+ @DBLocalName + ' FROM  DISK = @Source WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
				MOVE '''	+ @LogicalNameData + ''' TO @Data,
				MOVE '''	+ @LogicalNameLog + ''' TO @log;'
		END

		EXEC @ReturnCode = sp_executesql @SQL ,N'@Source varchar(200) ,@Data varchar(200) ,@Log varchar(200)' ,@Source ,@Data ,@Log
		IF @ReturnCode != 0
			SET @ReturnCode = 3

		IF @ReturnCode = 0 AND  @DBName = 'Transactor_Live'
		BEGIN
			SET @SQL = 'use ' + @DBLocalName + ';' 
			+ 'ALTER USER [TGSLUser] WITH LOGIN = [TGSLUser];'
			+ 'ALTER USER [TgslUserWeb] WITH LOGIN = [TgslUserWeb];'

			EXEC @ReturnCode = sp_executesql @SQL
			IF @ReturnCode != 0
				SET @ReturnCode = 4
		END

		IF @ReturnCode = 0 
		BEGIN
			SET @SQL = 'use ' + @DBLocalName + ';' 
			+ 'IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[uspConfigureDatabase]'') AND type in (N''P'', N''PC''))
			      EXEC [dbo].[uspConfigureDatabase];'

			EXEC @ReturnCode = sp_executesql @SQL
			IF @ReturnCode != 0
				SET @ReturnCode = 4
		END

	END
	RETURN @ReturnCode
END







GO
