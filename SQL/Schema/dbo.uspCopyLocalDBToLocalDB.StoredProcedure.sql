USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspCopyLocalDBToLocalDB]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		01 Apr 2019
--Desc		Copy MHGSQL01\TGSLTest Instance database (Single data file single log file as per prodec)
--======================================
CREATE PROCEDURE [dbo].[uspCopyLocalDBToLocalDB]
	 @DBName varchar(200)
	,@DBLocalName  varchar(200) = NULL
AS

/*

	DECLARE @DBName varchar(200) = 'Test1'
	DECLARE @DBLocalName varchar(200) = 'Test2'
	EXEC [dbo].[uspCopyLocalDBToLocalDB] @DBName ,@DBLocalName

*/
BEGIN
	SET NOCOUNT ON
	IF @@ServerName =  'MHGSQL01\TGSL'
		RETURN 1

	DECLARE @Source Nvarchar(200) = ''
	EXEC [DBA].[dbo].[uspBackupDatabase] @DBName ,@Source out

	DECLARE @ReturnCode int
	EXEC @ReturnCode = [dbo].[uspRestoreLocalDatabase] @DBName ,@DBLocalName ,@Source

	RETURN 	@ReturnCode
END

GO
