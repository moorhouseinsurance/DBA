USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspReportHighUsageProcedures]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		03 Apr 2019
--Desc		Procedure stats. Rates are per day
--======================================
CREATE PROCEDURE [dbo].[uspReportHighUsageProcedures]
	 @DBName varchar(200) = NULL
	,@StatisticOrder  varchar(200)
	,@Topcount int = 10
AS
/*
	DECLARE  @DBName varchar(200) -- = 'Transactor_Live'
			,@StatisticOrder  varchar(200) = 'WriteRate'  --'Executions'  ,'Reads' ,'Writes' ,'Time' ,'ExecutionRate' ,'ReadRate ,'WriteRate'
			,@Topcount int --= 10


	EXEC [dbo].[uspReportHighUsageProcedures] @DBName ,@StatisticOrder ,@Topcount

*/
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET @topcount = ISNULL(@TOPCOUNT,10)
	DECLARE @Now datetime = getdate()

	;WITH [D] AS
	(
		SELECT 
			 [EST].[dbid]
			,[EST].[objectid] 
			,CASE WHEN datediff(day ,[EQS].[creation_time] ,@Now) = 0 THEN 1 ELSE datediff(DAY ,[EQS].[creation_time] ,@Now) END AS [CompiledTime]
			,[EQS].[creation_time]
			,[EQS].[execution_count]
			,[EQS].[total_logical_reads]
			,[EQS].[last_logical_reads]
			,[EQS].[total_logical_writes]
			,[EQS].[last_logical_writes]
			,[EQS].[total_worker_time]
			,[EQS].[last_worker_time]
			,[EQS].[total_elapsed_time]/1000000 [total_elapsed_time_in_S]
			,[EQS].[last_elapsed_time]/1000000 [last_elapsed_time_in_S]
			,[EQS].[last_execution_time]
		FROM 
			sys.dm_exec_query_stats AS [EQS]
			CROSS APPLY sys.dm_exec_sql_text([EQS].[sql_handle]) [EST]
		--	CROSS APPLY sys.dm_exec_query_plan([EQS].[plan_handle]) AS [EQP]
		WHERE
			[EST].[Objectid] IS NOT NULL
			AND (@DBName IS NULL OR @DBName = db_name([EST].dbid))
	)

	SELECT TOP (@Topcount)
		 db_name([D].[dbid]) AS [Database]
		,object_name([D].objectid ,[D].dbid) AS [Procedure]
		,([D].[execution_count]/[CompiledTime]) AS [ExecutionRate] 
		,([D].[Total_logical_reads]/[CompiledTime]) AS [ReadRate]
		,([D].[Total_logical_writes]/[CompiledTime]) AS [WriteRate]
		,[D].[creation_time]
		,[D].[execution_count]
		,[D].[total_logical_reads]
		,[D].[last_logical_reads]
		,[D].[total_logical_writes]
		,[D].[last_logical_writes]
		,[D].[total_worker_time]
		,[D].[last_worker_time]
		,[D].[total_elapsed_time_in_S]
		,[D].[last_elapsed_time_in_S]
		,[D].[last_execution_time]
	FROM 
		[D]
	ORDER BY
		CASE @StatisticOrder
			WHEN 'Executions' THEN [D].[execution_count]
			WHEN 'Reads' THEN [D].[Total_logical_reads]
			WHEN 'Writes' THEN [D].[Total_logical_writes]
			WHEN 'Time' THEN [D].[Total_worker_time]
			WHEN 'ExecutionRate'	THEN [D].[execution_count]/[CompiledTime]
			WHEN 'ReadRate'			THEN [D].[Total_logical_reads]/[CompiledTime]
			WHEN 'WriteRate'		THEN [D].[Total_logical_writes]/[CompiledTime]
		END
		DESC
		OPTION(RECOMPILE)
END


GO
