--======================================
--Author	D. Hostler
--Date		23 Jan 2020
--Desc		Record and Report blocked Processes
--======================================
alter PROCEDURE [dbo].[uspReportBlockedProcess]
	 @StartDatetime datetime
AS
/*

	DECLARE @StartDatetime datetime = '2020-01-28 11:27:00.340'
	exec [dbo].[uspReportBlockedProcess] @StartDatetime

*/
BEGIN

	DECLARE @CSS nvarchar(max) =
		'<style type="text/css">
		.box-table
		{
		font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
		font-size: 12px;
		text-align: left;
		border-collapse: collapse;
		border-top: 7px solid #9baff1;
		border-bottom: 7px solid #9baff1;
		}
		.box-table th
		{
		font-size: 13px;
		font-weight: normal;
		background: #b9c9fe;
		border-right: 2px solid #9baff1;
		border-left: 2px solid #9baff1;
		border-bottom: 2px solid #9baff1;
		color: #039;
		}
		.box-table td
		{
		border-right: 1px solid #aabcfe;
		border-left: 1px solid #aabcfe;
		border-bottom: 1px solid #aabcfe;
		color: #669;
		}
		.box-table tr:nth-child(odd) { background-color:#eee; }
		.box-table tr:nth-child(even) { background-color:#fff; }
		</style>
		'
		DECLARE  @Html nvarchar(MAX)
				,@query nvarchar(MAX) = ';WITH [CTE] AS
(
	SELECT
		 [HeadBlocker]	AS [HeadBlocker]
		,[PDBID]			AS [DBID]
		,[BSPID] 		AS [PSPID]
		,cast(0	as smallint)	AS [BSPID]
		,[BName]		AS [Name]
		,[BType]		AS [Type]
		,[Bhostname]	AS [hostname]
		,[BProgram]		AS [Program]
		,[BLoginName]	AS [LoginName]
		,[BLoginTime]	AS [LoginTime]
		,[BScript]		AS [Script]
		,CAST(0	as bigint)			AS [WaitTime]
		,''/''+CAST(ROW_NUMBER() OVER (PARTITION BY 0 ORDER BY [PSPID]) AS VARCHAR(max)) AS [Path]
		,0 AS [Level]
		,[BlockedProcessID]
		,[PLastWaitType]
	FROM 
		[DBA].[dbo].[BlockedProcess]
	WHERE 
		[PolledDateTime] = ''{@StartDatetime}''
		AND [HeadBlocker] = 1
	UNION ALL
	SELECT
		 [T].[HeadBlocker]	AS [HeadBlocker]
		,[PDBID]			AS [DBID]
		,[T].[PSPID] 		AS [PSPID]
		,[T].[BSPID] 		AS [BSPID]
		,[T].[PName]		AS [Name]
		,[T].[PType]		AS [Type]
		,[T].[Phostname]	AS [hostname]
		,[T].[PProgram]		AS [Program]
		,[T].[PLoginName]	AS [LoginName]
		,[T].[PLoginTime]	AS [LoginTime]
		,[T].[PScript]		AS [Script]
		,[T].[PWaitTime]	 AS [WaitTime]	
		,[Path] + ''/'' + CAST(ROW_NUMBER() OVER (PARTITION BY [T].[BSPID] ORDER BY [T].[PSPID]) AS VARCHAR(max))
		,[level] + 1
		,[T].[BlockedProcessID]
		,[T].[PLastWaitType]
	FROM
		[CTE]
	JOIN
		 [DBA].[dbo].[BlockedProcess] [T] ON [CTE].[PSPID] = [T].[BSPID]
	WHERE 
		[PolledDateTime] = ''{@StartDatetime}''
)
   
SELECT
	 CASE WHEN [BSPID] = 0 THEN ''HeadBlock'' ELSE '''' END AS [HeadBlock]
	,[PSPID]
	,CASE WHEN [BSPID] = 0 Then '''' ELSE [BSPID] END AS [BSPID]
	,[WaitTime]/1000 AS [WaitTime (s)]	
	,DB_NAME([DBID]) AS [Database]
	,[Name]
	,[Type]
	,[LoginName]
	,FORMAT([LoginTime],''dd/MM/yyyy hh:mm'') AS [LoginTime]
	,[hostname]
	,[Program]
	,[Script]
	,''https://www.sqlskills.com/help/waits/'' + [PLastWaitType] AS [WaitType]
	,[BlockedProcessID] AS [LogID]
	,[Path] AS [BlockOrder]

INTO 
	#dynSql
FROM
	[CTE]
' 
		SET @query = REPLACE(@query ,'{@StartDateTime}' ,convert(varchar(50),@StartDateTime,13))
		DECLARE @orderBy varchar(200) = 'ORDER BY [BlockOrder]';
		SELECT @QUERY

		EXEC [Shared].[dbo].[uspQueryToHtmlTable]  @query = @query ,@orderBy = @orderBy ,@Html = @html OUTPUT;

		DECLARE @SubTitle varchar(50) 
		SET @SubTitle = '<h2>Blocking Processes</h2>
		'
		DECLARE @Footer varchar(8000) = '
		<h4>Key</h4>
		<table>
		<tr><td>HeadBlock</td><td>If marked HeadBlock this is the start of a block chain.</td><tr>
		<tr><td><tr><td>PSPID </td><td> Server Process ID of this process, If this is the Headblock this is the process to kill to free up the chain.</td><tr>
		<tr><td>BSPID </td><td> Server Process ID of the Blocking process</td><tr>
		<tr><td>Waitime  (S) </td><td> Amount of time the process has been blocked in seconds</td><tr>
		<tr><td>Database </td><td> Database on which the process is executing</td><tr>
		<tr><td>Name </td><td> Name of the Procedure.View or function which is blocked, if empty then check the script column for non DB Object session code being run.</td><tr>
		<tr><td>Type </td><td> Procedure View or function </td><tr>
		<tr><td>LoginName </td><td> Person or account running the Process</td><tr>
		<tr><td>hostname </td><td> Machine connected to this session running the code</td><tr>
		<tr><td>Program </td><td> Name of client program running the code e.g. SSMS</td><tr>
		<tr><td>Script </td><td> First 500 characters of the script/procedure being run to help diagnose quickly or if name of procedure is blank.</td><tr>
		<tr><td>LogID </td><td> ID of this record with full blocking information recorded in Table [DBA].[dbo].[BlockedPRocess]</td><tr>
		<tr><td>BlockOrder </td><td> Hierarchical representation ofthe blocking order.</td><tr>
		</table>
		
		<h4>Wait Information</h4>
		List of Wait types available at https://www.sqlskills.com/help/waits/</br>
		For Decoding KEY: or PAGE: WaitResources see https://littlekendra.com/2016/10/17/decoding-key-and-page-waitresource-for-deadlocks-and-blocking/
		For Decoding TAB:DatabaseID:Object_ID:n WaitResource use DB_Name(DatabaseID) and OBJECT_Name(Object_ID)
		'
		
		SET @Html = @CSS + @SubTitle + @Html + @Footer

		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'Exchange Server',
			@recipients = 'DHostler@Constructaquote.com;jeremai.smith@constructaquote.com;Jonathan.Miles@constructaquote.com',
			@subject = 'Blocking processes',
			@body = @Html,
			@body_format = 'HTML',
			@query_no_truncate = 1,
			@attach_query_result_as_file = 0;
		SELECT @Html

END
GO
