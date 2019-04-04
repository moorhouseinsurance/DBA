IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTrace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspTrace]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------
-- Name	D. Hostler
-- Date 26 Sep 2018
-- Desc Based on https://www.mssqltips.com/sqlservertip/1715/scheduling-a-sql-server-profiler-trace/
-- Docs:	https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-setfilter-transact-sql?view=sql-server-2017
-------------------------------------------------------

CREATE PROCEDURE [dbo].[uspTrace] 
	 @Folder nvarchar(200)
	,@RunPeriodMinutes int = 60
	,@MaxFileSizeMb int = 200
	,@DatabaseName nvarchar(250) = NULL
AS
/*
	--Enable xp_cmdshell
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE
	EXEC sp_configure 'xp_cmdshell', 1
	RECONFIGURE
	--Start profiler trace
	EXEC [DBA].[dbo].[uspTrace] @Folder ="L:\sql_traces\TGSL" ,@RunPeriodMinutes = 5 ,@MaxFileSizeMb = 100 ,@DatabaseName='Transactor_Live'
	-- Disable  xp_cmdshell
	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE
	EXEC sp_configure 'show advanced options', 0
	RECONFIGURE
	--Show trace details
	select * FROM ::fn_trace_getinfo(default)
	--Stop trace with ID @TraceID
	--EXEC sp_trace_SETstatus @traceid = 	2	, @status = 0; -- Stop/pause Trace
	--EXEC sp_trace_SETstatus @traceid = 	2	, @status = 2; -- Close trace and delete it from the server

	--List Columns for filters
	SELECT * FROM sys.trace_columns

	SELECT * INTO MyTraceTemp FROM ::fn_trace_gettable('L:\sql_traces\TGSL\{Directory}\Trace.trc', default)

	SELECT top 100 [CPU] ,[Duration] ,[Reads] ,[Writes]   ,[LoginName] , [StartTime] ,[EndTime] ,[ApplicationName],[NTUserName],[TextData]  FROM MyTraceTemp where textdata is not null
	order by cpu desc

	SELECT top 100 [CPU] ,[Duration] ,[Reads] ,[Writes]   ,[LoginName] , [StartTime] ,[EndTime] ,[ApplicationName],[NTUserName],[TextData]  FROM MyTraceTemp where textdata is not null 
	order by reads desc

	SELECT top 100 [CPU] ,[Duration] ,[Reads] ,[Writes]   ,[LoginName] , [StartTime] ,[EndTime] ,[ApplicationName],[NTUserName],[TextData]  FROM MyTraceTemp where textdata is not null
	order by writes desc

	SELECT top 100 [CPU] ,[Duration] ,[Reads] ,[Writes]   ,[LoginName] , [StartTime] ,[EndTime] ,[ApplicationName],[NTUserName],[TextData]  FROM MyTraceTemp where textdata is not null 
	order by duration desc

*/
BEGIN

	SET NOCOUNT ON

	DECLARE @StopTime datetime ; SET @StopTime = dateadd(mi ,@RunPeriodMinutes ,getdate())
	DECLARE @StartDatetime varchar(13) ; SET @StartDatetime = convert(char(8),getdate(),112) + '_' + cast(replace(convert(varchar(5),getdate(),108),':','') AS char(4)) --['YYYYMMDD_HHMM']
	DECLARE @rc int
	DECLARE @TraceID int
	DECLARE @TraceFile nvarchar(100)
	DECLARE @cmd nvarchar(2000)
	DECLARE @msg nvarchar(200)
	DECLARE @MaxFileSize BIGINT = @MaxFileSizeMb
	IF right(@Folder,1)<>'\' SET @Folder = @Folder + '\'
	BEGIN
		SET @cmd = 'dir ' + @Folder
		EXEC @rc = master..xp_cmdshell @cmd ,no_output
	END

	IF (@rc != 0) 
	BEGIN 
		SET @msg = 'The specified folder ' + @Folder + 'does not exist, Please specify an existing drive:\folder '+ cast(@rc AS varchar(10)) raiserror(@msg,10,1) RETURN(-1)
	END

	--Create new trace file folder
	SET @cmd = 'mkdir ' +@Folder+@StartDatetime
	EXEC @rc = master..xp_cmdshell @cmd,no_output

	IF (@rc != 0) 
	BEGIN 
		SET @msg = 'Error creating trace folder : ' + cast(@rc AS varchar(10)) 
		SET @msg = @msg + 'SQL Server 2005 or later instance require OLE Automation to been enabled' 
		raiserror(@msg,10,1)
		RETURN(-1)
	END

	SET @TraceFile = @Folder + @StartDatetime + '\trace'
	EXEC @rc = sp_trace_create @TraceID output, 2, @TraceFile ,@MaxFileSize ,@StopTime

	IF (@rc != 0) 
	BEGIN 
		SET @msg = 'Error creating trace : ' + cast(@rc AS varchar(10)) 
		raiserror(@msg,10,1) 
		RETURN(-1)
	END

	--Events from a trace file template export
	DECLARE @on bit
	SET @on = 1
	EXEC sp_trace_SETevent @TraceID, 14, 1, @on
	EXEC sp_trace_SETevent @TraceID, 14, 9, @on
	EXEC sp_trace_SETevent @TraceID, 14, 10, @on
	EXEC sp_trace_SETevent @TraceID, 14, 11, @on
	EXEC sp_trace_SETevent @TraceID, 14, 6, @on
	EXEC sp_trace_SETevent @TraceID, 14, 12, @on
	EXEC sp_trace_SETevent @TraceID, 14, 14, @on
	EXEC sp_trace_SETevent @TraceID, 15, 11, @on
	EXEC sp_trace_SETevent @TraceID, 15, 6, @on
	EXEC sp_trace_SETevent @TraceID, 15, 9, @on
	EXEC sp_trace_SETevent @TraceID, 15, 10, @on
	EXEC sp_trace_SETevent @TraceID, 15, 12, @on
	EXEC sp_trace_SETevent @TraceID, 15, 13, @on
	EXEC sp_trace_SETevent @TraceID, 15, 14, @on
	EXEC sp_trace_SETevent @TraceID, 15, 15, @on
	EXEC sp_trace_SETevent @TraceID, 15, 16, @on
	EXEC sp_trace_SETevent @TraceID, 15, 17, @on
	EXEC sp_trace_SETevent @TraceID, 15, 18, @on
	EXEC sp_trace_SETevent @TraceID, 17, 1, @on
	EXEC sp_trace_SETevent @TraceID, 17, 9, @on
	EXEC sp_trace_SETevent @TraceID, 17, 10, @on
	EXEC sp_trace_SETevent @TraceID, 17, 11, @on
	EXEC sp_trace_SETevent @TraceID, 17, 6, @on
	EXEC sp_trace_SETevent @TraceID, 17, 12, @on
	EXEC sp_trace_SETevent @TraceID, 17, 14, @on
	EXEC sp_trace_SETevent @TraceID, 10, 9, @on
	EXEC sp_trace_SETevent @TraceID, 10, 2, @on
	EXEC sp_trace_SETevent @TraceID, 10, 10, @on
	EXEC sp_trace_SETevent @TraceID, 10, 6, @on
	EXEC sp_trace_SETevent @TraceID, 10, 11, @on
	EXEC sp_trace_SETevent @TraceID, 10, 12, @on
	EXEC sp_trace_SETevent @TraceID, 10, 13, @on
	EXEC sp_trace_SETevent @TraceID, 10, 14, @on
	EXEC sp_trace_SETevent @TraceID, 10, 15, @on
	EXEC sp_trace_SETevent @TraceID, 10, 16, @on
	EXEC sp_trace_SETevent @TraceID, 10, 17, @on
	EXEC sp_trace_SETevent @TraceID, 10, 18, @on
	EXEC sp_trace_SETevent @TraceID, 12, 1, @on
	EXEC sp_trace_SETevent @TraceID, 12, 9, @on
	EXEC sp_trace_SETevent @TraceID, 12, 11, @on
	EXEC sp_trace_SETevent @TraceID, 12, 6, @on
	EXEC sp_trace_SETevent @TraceID, 12, 10, @on
	EXEC sp_trace_SETevent @TraceID, 12, 12, @on
	EXEC sp_trace_SETevent @TraceID, 12, 13, @on
	EXEC sp_trace_SETevent @TraceID, 12, 14, @on
	EXEC sp_trace_SETevent @TraceID, 12, 15, @on
	EXEC sp_trace_SETevent @TraceID, 12, 16, @on
	EXEC sp_trace_SETevent @TraceID, 12, 17, @on
	EXEC sp_trace_SETevent @TraceID, 12, 18, @on
	EXEC sp_trace_SETevent @TraceID, 13, 1, @on
	EXEC sp_trace_SETevent @TraceID, 13, 9, @on
	EXEC sp_trace_SETevent @TraceID, 13, 11, @on
	EXEC sp_trace_SETevent @TraceID, 13, 6, @on
	EXEC sp_trace_SETevent @TraceID, 13, 10, @on
	EXEC sp_trace_SETevent @TraceID, 13, 12, @on
	EXEC sp_trace_SETevent @TraceID, 13, 14, @on

	--Filter from a tarce file export
	DECLARE @intfilter int
	DECLARE @bigintfilter bigint

	EXEC sp_trace_SETfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 1929ad39-997b-48ce-b11f-0c8a8280cdfd'
	-----------------------------------------------------------------------------
	-- This filter is added to exclude all profiler traces.
	EXEC sp_trace_SETfilter @TraceID, 10, 0, 7, N'SQL Profiler%'

	IF @DatabaseName IS NOT NULL
		EXEC sp_trace_SETfilter @TraceID, 35, 0, 0, @DatabaseName

	-- SET the trace status to start
	EXEC sp_trace_SETstatus @TraceID, 1 -- start trace

	select 'Trace id = ', @TraceID, 'Path=', @Folder+@StartDatetime+'\'

	RETURN
END
GO

