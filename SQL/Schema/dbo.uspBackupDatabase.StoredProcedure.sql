USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspBackupDatabase]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
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
