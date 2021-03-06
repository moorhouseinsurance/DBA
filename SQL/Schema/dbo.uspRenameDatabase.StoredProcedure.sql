USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspRenameDatabase]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		06 Nov 2019
--Desc		Rename Database, Does not change log or mdf filenames.
--======================================
CREATE PROCEDURE [dbo].[uspRenameDatabase]
	 @DBSourceName varchar(200)
	,@DBTargetName  varchar(200) = NULL
AS

/*

DECLARE 
	 @DBSourceName varchar(200) ='temp1'
	,@DBTargetName  varchar(200) = 'temp2'

EXECUTE [dbo].[uspRenameDatabase] @DBSourceName ,@DBTargetName

*/
BEGIN
	SET NOCOUNT ON
	DECLARE @ReturnCode int = 0

	IF @@ServerName =  'MHGSQL01\TGSL'
		RETURN 1

	IF @DBTargetName IS NULL
		SET @DBTargetName = @DBSourceName + FORMAT(getdate(), 'yyyyMMdd_hhmm')

	IF 	@DBSourceName IS NULL
		RETURN 2

	DECLARE @ExistsLocalDB bit
	SET @ExistsLocalDB = (SELECT CASE WHEN COUNT(*) != 0 THEN 1 ELSE 0 END FROM [sys].[Databases] WHERE [Name] = @DBSourceName)

	IF @ExistsLocalDB = 0
		RETURN 2

	BEGIN
	
		DECLARE @SQL NVARCHAR(2000);
		SET @SQL = N'
			use master;
			ALTER DATABASE '	+ @DBSourceName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
			EXEC master..sp_renamedb  ''' + @DBSourceName +''',''' + @DBTargetName +''';
			ALTER DATABASE '	+ @DBTargetName + ' SET MULTI_USER WITH ROLLBACK IMMEDIATE;'	
PRINT @SQL
	--	EXEC @ReturnCode = sp_executesql @SQL 
		IF @ReturnCode != 0
			SET @ReturnCode = 3
	END
	RETURN @ReturnCode
END







GO
