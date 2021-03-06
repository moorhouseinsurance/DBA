USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[SearcgTables]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SearcgTables] AS
BEGIN


DECLARE @TableName nvarchar(256), @ColumnName nvarchar(128), @SearchStr2 nvarchar(110)
SET  @TableName = ''

CREATE TABLE #SearchTablesSQL ([ID] bigint IDENTITY(1,1) ,[EXESQL] nvarchar(1000),ColumnName nvarchar(370), ColumnValue nvarchar(3630))

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE    @SearchStr nvarchar(100) = 'testFSA1.rtf'
SET @SearchStr = QUOTENAME('%' + @SearchStr + '%','''')

DECLARE  @SQL varchar(1000) = ' 
UNION SELECT ''@TableColumnName'' AS [Column] ,@ColumnName AS [Text] FROM @TableName WHERE @ColumnName LIKE @SearchStr'

INSERT INTO #SearchTablesSQL ([EXESQL] ,[ColumnName])
SELECT 
	REPLACE(
	REPLACE(
	REPLACE(
	REPLACE(@SQL,'@ColumnName',QUOTENAME(C.Column_name))
	,'@TableName',QUOTENAME(C.Table_name))
	,'@SearchStr' ,@SearchStr)
	,'@TableColumnName' ,QUOTENAME(C.Table_name)+'.'+QUOTENAME(C.Column_name))
	,C.Column_name
FROM
	INFORMATION_SCHEMA.COLUMNS c
	INNER JOIN INFORMATION_SCHEMA.TABLES t on c.table_schema = t.table_schema and c.Table_name = t.table_name
WHERE
	C.TABLE_NAME NOT LIKE 'Customer_%'
	AND T.TABLE_TYPE = 'BASE TABLE'
	AND C.DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext')
	AND  t.table_schema = 'dbo'

--DECLARE @ID bigint = 1
 
--WHILE 1 = 1
--	SELECT @SQL = [EXESQL] FROM #SearchTablesSQL WHERE [ID] = @ID

END 
GO
