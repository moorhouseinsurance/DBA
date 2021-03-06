USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspCopyLiveDBToLocalDB]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		01 Apr 2019
--Desc		Copy MHGSQL01\TGSL Instance database (Single data file single log file as per prodec)
--======================================
CREATE PROCEDURE [dbo].[uspCopyLiveDBToLocalDB]
	 @DBName varchar(200)
	,@DBLocalName  varchar(200) = NULL
AS

/*

	DECLARE @DBName varchar(200) = 'Calculators'
	DECLARE @DBLocalName varchar(200) = 'Calculators_2143'
	EXEC [dbo].[uspCopyLiveDBToLocalDB] @DBName ,@DBLocalName

*/
BEGIN
	SET NOCOUNT ON
	IF @@ServerName =  'MHGSQL01\TGSL'
		RETURN 1

	DECLARE @Source Nvarchar(200) = ''
	EXEC [MHGSQL01\TGSL].[DBA].[dbo].[uspBackupDatabase] @DBName ,@Source out

	DECLARE @ReturnCode int
	EXEC @ReturnCode = [dbo].[uspRestoreDatabase] @DBName ,@DBLocalName ,@Source

	RETURN 	@ReturnCode
END

GO
