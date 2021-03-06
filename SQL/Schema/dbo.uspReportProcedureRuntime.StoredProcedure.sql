USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspReportProcedureRuntime]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		29 Apr 2019
--Desc		PRocedure execution time stats
--======================================
CREATE PROCEDURE [dbo].[uspReportProcedureRuntime]
	  @DBName varchar(200)
	 ,@TopTen bit = 1
AS

/*

	DECLARE	 @DBName varchar(200) = 'Calculators'
			,@TopTen bit 
	EXEC [dbo].[uspReportProcedureRuntime] @DBName ,@TopTen

*/
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @SQL varchar(2000) = '
	use {@DBName}
	;

	SELECT {@Top}
		QUOTENAME(OBJECT_SCHEMA_NAME([object_id])) 
		+ ''.'' + QUOTENAME(OBJECT_NAME([object_id])) AS [procedure]
		,[last_execution_time]
		,CONVERT(DECIMAL(30,2), total_worker_time * 1.0 / execution_count) AS [avg_execution_time]
		,[max_worker_time]
	FROM 
		[sys].[dm_exec_procedure_stats]
	WHERE 
		database_id = DB_ID()
	ORDER BY avg_execution_time DESC;
	'
	SET @SQL = REPLACE(@SQL,'{@DBName}',@DBName);
	SET @SQL = REPLACE(@SQL,'{@Top}',CASE WHEN @TopTen = 1 THEN 'Top 10' ELSE '' END)
	EXEC (@SQL)

END


GO
