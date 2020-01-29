
--======================================
--Author	D. Hostler
--Date		24 Jan 2020
--Desc		List Object dependencies
--======================================
ALTER PROCEDURE [dbo].[uspReportObjectDependencies]
	  @ObjectName varchar(255)  
	 ,@DBName varchar(200)
AS
/*
	DECLARE @ObjectName varchar(255) =  'MI_Informationa' 
	,@DBName varchar(200)

	exec [dbo].[uspReportObjectDependencies]  @ObjectName ,@DBName

*/

BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SET @DBName = CASE WHEN @DBName IS NULL THEN 'Transactor_Live' ELSE @DBName END

	DECLARE @SQL varchar(2000) = '
	use {@DBName}
	;
	SELECT 
		 ''[''+OBJECT_Schema_Name([referencing_id]) +''].[''+ OBJECT_NAME ([referencing_id]) + '']'' AS [Referencing_object]
		,''[''+ISNULL([referenced_database_name],DB_Name(DB_ID())) +''].[''+ OBJECT_Schema_Name([referenced_id]) +''].[''+  referenced_entity_name+ '']'' AS [Referenced_object]	
	FROM 
		sys.sql_expression_dependencies
	WHERE 
		  referenced_entity_name =  ''{@ObjectName}''
	ORDER BY
		[Referencing_object]

	'
	SET @SQL = REPLACE(@SQL,'{@DBName}',@DBName);
	SET @SQL = REPLACE(@SQL,'{@ObjectName}',@ObjectName);
	SELECT @SQL
	EXEC (@SQL)

END
GO