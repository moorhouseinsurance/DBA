IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspJobScheduleReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspJobScheduleReport]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
---------------------------------
--Author:	D,Hostler
--Date:		04 Apr 2019
--Desc		Create Index script
--Ref		https://www.sqlservercentral.com/forums/topic/list-all-jobs-and-their-schedules
---------------------------------------

CREATE PROCEDURE [dbo].[uspJobScheduleReport] 
	@EnabledDisabledAll int = NULL --1 Enabled: 0 Disabled : NULL All
AS
/*
	DECLARE @EnabledDisabledAll int = 1
	exec  [dbo].[uspJobScheduleReport] @EnabledDisabledAll
*/
BEGIN

	;WITH [RD] AS
	(
		SELECT 
			[job_id]
			,max(run_duration) AS [run_duration]
		FROM 
			[msdb].[dbo].[sysjobhistory]
		GROUP BY 
			[job_id]
	)
	,[CR] AS
	(
	
		SELECT
			 [SJ].[Name]
			,[SJ].[Enabled]
			,[SS].[freq_type]
			,[RD].[run_duration]
			,[SS].[freq_subday_interval]
			,[SS].[freq_subday_type]
			,CASE [SJS].[Next_run_time] WHEN 0 THEN [SS].[active_start_date] ELSE [SJS].[next_run_date] END  AS [Date]
			,CASE [SJS].[Next_run_time] WHEN 0 THEN [SS].[active_start_time] ELSE [SJS].[next_run_time] END  AS [Time]
		FROM
			[msdb].[dbo].[sysjobs] AS [SJ]
			LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [SJS] ON [SJ].[job_id] = [SJS].[job_id]
			INNER JOIN [msdb].[dbo].[sysschedules] AS [SS] ON [SJS].[schedule_id] = [SS].[schedule_id]
			LEFT JOIN [RD] ON [SJ].[job_id] = [RD].[job_id]
		WHERE 
			([SJ].[Enabled] = @EnabledDisabledAll) OR (@EnabledDisabledAll IS NULL)
	)
	SELECT 
		 [CR].[Name] AS [Job Name]
		,CASE [CR].[Enabled] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END AS [Job Enabled]
		,CASE [CR].[freq_type]
			  WHEN 1 THEN 'Once'
			  WHEN 4 THEN 'Daily'
			  WHEN 8 THEN 'Weekly'
			  WHEN 16 THEN 'Monthly'
			  WHEN 32 THEN 'Monthly relative'
			  WHEN 64 THEN 'When SQLServer Agent starts'
		 END AS [Frequency] 
		,CASE [CR].[Date]
			  WHEN 0 THEN null
			  ELSE
			  substring(convert(varchar(15),[CR].[Date]),1,4) + '/' + 
			  substring(convert(varchar(15),[CR].[Date]),5,2) + '/' + 
			  substring(convert(varchar(15),[CR].[Date]),7,2)
		 END AS [Start Date]
		,CASE len([CR].[Time])
			  WHEN 1 THEN cast('00:00:0' + right([CR].[Time],2) as char(8))
			  WHEN 2 THEN cast('00:00:' + right([CR].[Time],2) as char(8))
			  WHEN 3 THEN cast('00:0' 
					+ Left(right([CR].[Time],3),1)  
					+':' + right([CR].[Time],2) as char (8))
			  WHEN 4 THEN cast('00:' 
					+ Left(right([CR].[Time],4),2)  
					+':' + right([CR].[Time],2) as char (8))
			  WHEN 5 THEN cast('0' + Left(right([CR].[Time],5),1) 
					+':' + Left(right([CR].[Time],4),2)  
					+':' + right([CR].[Time],2) as char (8))
			  WHEN 6 THEN cast(Left(right([CR].[Time],6),2) 
					+':' + Left(right([CR].[Time],4),2)  
					+':' + right([CR].[Time],2) as char (8))
		   END AS [Start Time]
		   ,
		   CASE len(run_duration)
			  WHEN 1 THEN cast('00:00:0'+ cast(run_duration as char) as char (8))
			  WHEN 2 THEN cast('00:00:' + cast(run_duration as char) as char (8))
			  WHEN 3 THEN cast('00:0'   + Left(right(run_duration,3),1) +':' + right(run_duration,2) as char (8))
			  WHEN 4 THEN cast('00:' + Left(right(run_duration,4),2)  +':' + right(run_duration,2) as char (8))
			  WHEN 5 THEN cast('0'  + Left(right(run_duration,5),1) +':' + Left(right(run_duration,4),2) +':' + right(run_duration,2) as char (8))
			  WHEN 6 THEN cast(Left(right(run_duration,6),2) +':' + Left(right(run_duration,4),2) +':' + right(run_duration,2) as char (8))
		   END AS [Max Duration]
		   ,CASE([CR].[freq_subday_interval])
			  WHEN 0 THEN 'Once'
			  ELSE cast('Every ' 
					+ right([CR].[freq_subday_interval],2) 
					+ ' '
					+     CASE[CR].[freq_subday_type]
							 WHEN 1 THEN 'Once'
							 WHEN 4 THEN 'Minutes'
							 WHEN 8 THEN 'Hours'
						  END as char(16))
			END AS [Subday Frequency]
	FROM 
		[CR]
	ORDER BY 
		[Start Time]

END
GO

