IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCopyRemoteCalculatorsDBToLocalDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspCopyRemoteCalculatorsDBToLocalDB]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspCopyRemoteCalculatorsDBToLocalDB]
	@DBLocalName varchar(200)
AS

/*
	DECLARE @DBLocalName varchar(200) = 'Calculators_Dev2026'
	EXEC [dbo].[uspCopyRemoteCalculatorsDBToLocalDB] @DBLocalName 

*/
BEGIN
	DECLARE @Source varchar(200) = ''
	DECLARE @Log varchar(200) = ''
	DECLARE @Data varchar(200) = ''

	exec [MHGSQL01\TGSLTest].[DBA].[dbo].[uspBackupCalculators]
	exec [MHGSQL01\TGSL].[DBA].[dbo].[uspBackupCalculators]

	IF @@ServerName =  'MHGSQL01\TGSLTEST'
	BEGIN
		SET @Source = N'L:\sql_backups\TGSL\Calculators_To_Test.bak'
		SET @log = N'L:\SQL_Logs\TGSLTest\'  + @DBLocalName + '.ldf'
		SET @Data = N'S:\SQL_Data\TGSLTest\' + @DBLocalName + '.mdf'
	END
	IF @@ServerName =  'MHGSQL01\TGSL'
	BEGIN
		SET @Source = N'L:\sql_backups\TGSLTest\Calculators_' + CONVERT(VARCHAR(10), GETDATE(), 112) +'.bak'
		SET @log = N'L:\SQL_Logs\TGSL\'  + @DBLocalName + '.ldf'
		SET @Data = N'S:\SQL_Data\TGSL\' + @DBLocalName + '.mdf'
	END

	IF 	@Source != ''
	BEGIN
		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = 
		N'
		ALTER DATABASE '	+ @DBLocalName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		RESTORE DATABASE '	+ @DBLocalName + ' FROM  DISK = @Source WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
			MOVE N''Calculators'' TO @Data,
			MOVE N''Calculators_log'' TO @log;
		ALTER DATABASE '	+ @DBLocalName + ' SET MULTI_USER WITH ROLLBACK IMMEDIATE'	

		EXEC sp_executesql @SQL ,N'@Source varchar(200) ,@Data varchar(200) ,@Log varchar(200)' ,@Source ,@Data ,@Log

		SET @SQL = 'use ' + @DBLocalName + ';' 
		+ 'ALTER USER [TGSLUser] WITH LOGIN = [TGSLUser];'
		+ 'ALTER USER [TgslUserWeb] WITH LOGIN = [TgslUserWeb];'

		EXEC sp_executesql @SQL

	END
END

GO

