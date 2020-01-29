--======================================
--Author	D. Hostler
--Date		23 Jan 2020
--Desc		Record and Report blocked Processes
--======================================
CREATE PROCEDURE [dbo].[uspBlockedProcessInsert]
	 @wait_time_threshold int = 20000 --milliseconds
AS
/*

	DECLARE @wait_time_threshold int = 20000 
	exec [dbo].[uspBlockedProcessInsert] @wait_time_threshold

*/
BEGIN
	DECLARE @TimeStamp datetime = GETDATE()
	;WITH [B] AS
	(
		SELECT 
			 [P].[DBID] AS [PDBID]
			,[P].[SPID] AS [PSPID]
			,[PO].[Name] AS [PName]
			,[PO].[Type_Desc] AS [PType]
			,[P].[hostname] AS [Phostname]
			,[P].[program_name] AS [PProgram]
			,[P].[cmd] AS [Pcmd]
			,[P].[loginame] AS [PLoginName]
			,[P].[login_time] AS [PLoginTime]
			,[P].[last_batch] AS [PLastBatch]
			,convert(varchar(500),[PS].[text]) AS [PScript]
			,[P].[WaitTime] AS [PWaitTime]
			,[P].[LastWaitType] AS [PLastWaitType]
			,[P].[WaitResource] AS [PWaitResource]
			,[P].[Blocked] AS [BSPID]
			,[BO].[Name] AS [BName]
			,[BO].[Type_Desc] AS [BType]
			,[B].[hostname] AS [Bhostname]
			,[B].[program_name] AS [BProgram]
			,[B].[cmd] AS [Bcmd]
			,[B].[loginame] AS [BLoginName]
			,[B].[login_time] AS [BLoginTime]
			,[B].[last_batch] AS [BLastBatch]
			,CASE WHEN [B].[Blocked] = 0 THEN 1 ELSE 0 END AS [HeadBlocker]
			,convert(varchar(500),[BS].[text]) AS [BScript]
		FROM
			[SysProcesses] AS [P]
			LEFT JOIN [SysProcesses] AS [B] ON [P].[Blocked] = [B].[SPID]
			OUTER APPLY ::fn_get_sql([P].[sql_handle]) AS [PS]
			OUTER APPLY ::fn_get_sql([B].[sql_handle]) AS [BS]
			LEFT JOIN [sys].[objects] AS [PO] ON [PS].[objectid] = [PO].[object_id]
			LEFT JOIN [sys].[objects] AS [BO] ON [BS].[objectid] = [BO].[object_id]
		WHERE
			[P].[Blocked] != 0 
			AND [P].[waittime] > @wait_time_threshold
	)
	INSERT INTO [dbo].[BlockedProcess]
	SELECT
		 @TimeStamp AS [PolledDateTime]
		,[B].*
	FROM
		[B]
	;

	IF @@ROWCOUNT != 0
		Exec [dbo].[uspReportBlockedProcess] @TimeStamp

END
GO