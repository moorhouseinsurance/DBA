IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspBackupCalculators]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspBackupCalculators]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspBackupCalculators]
AS
BEGIN
	DECLARE @Destination varchar(200) = ''
	IF @@ServerName =  'MHGSQL01\TGSLTEST'
		SET @Destination = N'L:\sql_backups\TGSLTest\Calculators_' + CONVERT(VARCHAR(10), GETDATE(), 112) +'.bak'
	IF @@ServerName =  'MHGSQL01\TGSL'
		SET @Destination =N'L:\sql_backups\TGSL\Calculators_To_Test.bak'
	IF 	@Destination != ''
	BEGIN
		BACKUP DATABASE [Calculators] TO  DISK = @Destination WITH  COPY_ONLY, INIT,  NAME = N'Calculators', SKIP,  STATS = 10
	END
END

GO

