USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspBackupCalculators]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		04 Apr 2019
--Desc		Backup database
--======================================
CREATE PROCEDURE [dbo].[uspBackupCalculators]
AS
/*
	EXEC [dbo].[uspBackupCalculators]
*/
BEGIN
	DECLARE  @DBName varchar(200) = 'Calculators'
			,@BackupFile  varchar(200) 

	EXEC [dbo].[uspBackupDatabase] @DBName ,@BackupFile out	

	select @BackupFile
END


GO
