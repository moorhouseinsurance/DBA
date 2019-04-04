IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspBackup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspBackup]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspBackup]
AS
BEGIN
BACKUP DATABASE [Calculators] TO  DISK = N'L:\sql_backups\TGSL\Calculators_To_Test.bak' WITH  COPY_ONLY, INIT,  NAME = N'Calculators', SKIP,  STATS = 10
END

GO

