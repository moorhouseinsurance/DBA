USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspSearchTables]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		10 Dec 2019
--Desc		Search for character string in all tables in a given database, can exclude table with a given prefix
--======================================
CREATE PROCEDURE [dbo].[uspSearchTables]
	 @Database nvarchar(100)
	,@Schema nvarchar(100) 
	,@Str nvarchar(100)
	,@ExcludeTablePrefix nvarchar(100) 

 AS

/*
	DECLARE
		 @Database nvarchar(100) = 'Transactor_Live'
		,@Schema nvarchar(100) = 'dbo'
		,@Str nvarchar(100) = 'testFSA1.rtf'
		,@ExcludeTablePrefix nvarchar(100) ='Customer_'
	EXEC [uspSearchTables] @Database ,@Schema ,@Str ,@ExcludeTablePrefix

*/
BEGIN

	--SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF @Database IS NULL
		SET @Database = DB_Name()

	SET	@Database = QUOTENAME(@Database)

	DECLARE
		@SQLSynonym nvarchar(500) = 'DROP SYNONYM [dbo].[DBASearch_INFORMATION_SCHEMA_TABLES];
	CREATE SYNONYM [dbo].[DBASearch_INFORMATION_SCHEMA_TABLES] FOR @Database.[INFORMATION_SCHEMA].[TABLES]
	DROP SYNONYM [dbo].[DBASearch_INFORMATION_SCHEMA_COLUMNS];
	CREATE SYNONYM [dbo].[DBASearch_INFORMATION_SCHEMA_COLUMNS] FOR @Database.[INFORMATION_SCHEMA].[COLUMNS];'

	SET @SQLSynonym = REPLACE (@SQLSynonym,'@Database',@Database)

	EXEC (@SQLSynonym)

	DECLARE 
			 @TableName nvarchar(256) = ''
			,@ColumnName nvarchar(128)
			,@ExeSql nvarchar(max) = ''
			,@SQL varchar(1000) = ' 
	UNION ALL  SELECT ''@TableColumnName'' AS [Column] ,@ColumnName collate database_default AS [Text] FROM [Transactor_Live].[dbo].@TableName WHERE @ColumnName LIKE @SearchStr'
			,@BatchSize int =100
			,@BatchNumber int=1
			,@ResultCount int = 0
			,@ResultCountNew int = 0

	SET @Str = QUOTENAME('%' + @Str + '%','''')

	DECLARE @Results table ([Column] varchar(100) , [Text] varchar(500))

	WHILE 1 = 1
	BEGIN
		SET @ExeSQL = '';

		;WITH  [X] AS 
		(
			SELECT 
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(@SQL,'@ColumnName',QUOTENAME(C.Column_name))
				,'@TableName',QUOTENAME(C.Table_name))
				,'@SearchStr' ,@Str)
				,'@TableColumnName' ,QUOTENAME(C.Table_name)+'.'+QUOTENAME(C.Column_name)) AS [EXESQL]
				,Row_Number() OVER (Order by C.Table_name,C.Column_name) AS [RowNumber]
			FROM
				[dbo].[DBASearch_INFORMATION_SCHEMA_COLUMNS] c
				INNER JOIN [dbo].[DBASearch_INFORMATION_SCHEMA_TABLES] t on c.table_schema = t.table_schema and c.Table_name = t.table_name
			WHERE
				(@ExcludeTablePrefix IS NULL OR C.TABLE_NAME NOT LIKE @ExcludeTablePrefix + '%')
				AND T.TABLE_TYPE = 'BASE TABLE'
				AND C.DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext')
				AND (@Schema IS NULL OR  t.table_schema = @Schema)
		)
		SELECT
			@ExeSql = @ExeSql + [EXESQL] 
		FROM
			[X]
		WHERE
			[X].[RowNumber] BETWEEN ((@BatchNumber-1)*@BatchSize)+1 AND ((@BatchNumber)*@BatchSize)
	
		IF ISNULL(@ExeSQL,'') = ''
			BREAK

		SET @ExeSql = STUFF(@ExeSql,1,15,'USE ' + @Database +';')
		PRINT CAST (((@BatchNumber-1)*@BatchSize)+1 as varchar(10)) +'-' + CAST (((@BatchNumber)*@BatchSize) AS varchar(10))
		
		--select @ExeSql
		

		INSERT INTO @Results 
		EXEC (@ExeSql)

		SELECT @ResultCountNew = COUNT(*) FROM @Results
		IF @ResultCountNew > @ResultCount
		BEGIN
			SET @ResultCount = @ResultCountNew
			SELECT * FROM @Results
		END

		SET @BatchNumber = @BatchNumber + 1
	END

	SELECT * FROM @Results
END


GO
