USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspRestoreCalculators]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
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
