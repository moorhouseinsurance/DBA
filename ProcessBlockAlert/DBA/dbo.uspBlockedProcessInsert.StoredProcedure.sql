USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspBlockedProcessInsert]    Script Date: 03/06/2020 10:42:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
			,OBJECT_NAME([PS].[objectid],[P].[DBID]) AS [PName]
			,NULL AS [PType]
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
			,OBJECT_NAME([BS].[objectid],[B].[DBID]) AS [BName]
			,NULL AS [BType]
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
			OUTER APPLY sys.dm_exec_sql_text([P].[sql_handle]) AS [PS]
			OUTER APPLY sys.dm_exec_sql_text([B].[sql_handle]) AS [BS]
		WHERE 
			[P].[Blocked] != 0 
			AND [P].[waittime] > @wait_time_threshold
			AND [BS].[text] IS NOT NULL
	)
	INSERT INTO [dbo].[BlockedProcess]
	SELECT DISTINCT
		 @TimeStamp AS [PolledDateTime]
		,[B].*
		--INTO [BlockedProcess]
	FROM
		[B]
	;

	IF @@ROWCOUNT != 0
		Exec [dbo].[uspReportBlockedProcess] @TimeStamp

END

GO


