IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspBackupDatabase]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspBackupDatabase]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Backup database
--======================================
CREATE PROCEDURE [dbo].[uspBackupDatabase]
	 @DBName varchar(200)
	,@BackupFile  varchar(200) out

AS
/*
	DECLARE  @DBName varchar(200) = 'StagingTables'
			,@BackupFile  varchar(200) 

	EXEC [dbo].[uspBackupDatabase] @DBName ,@BackupFile out	

	select @BackupFile
*/
BEGIN
	IF @@ServerName =  'MHGSQL01\TGSLTEST'
		SET @BackupFile = N'L:\sql_backups\TGSLTest\' + @DBName+ '_'+ CONVERT(VARCHAR(10), GETDATE(), 112) +'.bak'
	IF @@ServerName =  'MHGSQL01\TGSL'
		SET @BackupFile =N'L:\sql_backups\TGSL\' + @DBName+ '_'+ CONVERT(VARCHAR(10), GETDATE(), 112) +'.bak'
	IF 	@BackupFile != ''
	BEGIN
		BACKUP DATABASE  @DBName TO  DISK = @BackupFile WITH  COPY_ONLY, INIT,  NAME = @DBName, SKIP,  STATS = 10
	END
END

GO

