IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspRestoreCalculators]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspRestoreCalculators]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspRestoreCalculators]
AS
BEGIN
	DECLARE @Source varchar(200) = ''
	DECLARE @Log varchar(200) = ''
	DECLARE @Data varchar(200) = ''

	exec [MHGSQL01\TGSLTest].[DBA].[dbo].[uspBackupCalculators]
	exec [MHGSQL01\TGSL].[DBA].[dbo].[uspBackupCalculators]

	IF @@ServerName =  'MHGSQL01\TGSLTEST'
	BEGIN
		SET @Source = N'L:\sql_backups\TGSL\Calculators_To_Test.bak'
		SET @log = N'L:\SQL_Logs\TGSLTest\Calculators.ldf'
		SET @Data = N'S:\SQL_Data\TGSLTest\Calculators.mdf'
	END
	IF @@ServerName =  'MHGSQL01\TGSL'
	BEGIN
		SET @Source = N'L:\sql_backups\TGSLTest\Calculators_' + CONVERT(VARCHAR(10), GETDATE(), 112) +'.bak'
		SET @log = N'L:\SQL_Logs\TGSL\Calculators.ldf'
		SET @Data = N'S:\SQL_Data\TGSL\Calculators.mdf'
	END

	IF 	@Source != ''
	BEGIN
		ALTER DATABASE [Calculators] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		RESTORE DATABASE [Calculators] FROM  DISK = @Source WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
			MOVE N'Calculators' TO @Data,
			MOVE N'Calculators_log' TO @log
		ALTER DATABASE [Calculators] SET MULTI_USER WITH ROLLBACK IMMEDIATE	
	END
END

GO

