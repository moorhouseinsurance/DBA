USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[SQLAgentJobLog]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Devlin Hostler
-- Create date: 06 Jan 2017
-- Description:SQL Agent Job History report
-- =============================================

CREATE PROCEDURE [dbo].[SQLAgentJobLog]
	@JobName nvarchar(50) = NULL	
AS
/*
	DECLARE @JobName nvarchar(50) = 'ETLOpenGIImport' 
	EXEC  [dbo].[SQLAgentJobLog]  @JobName

*/
BEGIN
	SELECT 
		--H.*,
		j.name AS [JobName]
		,step_name
		,msdb.dbo.agent_datetime(run_date, run_time) as [RunDateTime]
		,((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) AS [RunDurationMinutes]
		,[MESSAGE]
	FROM 
		msdb.dbo.sysjobs j 
		INNER JOIN msdb.dbo.sysjobhistory h  ON j.job_id = h.job_id 
	WHERE 
		j.enabled = 1  
		and (j.name = @JobName OR @JobName IS NULL)
		and step_name = '(Job outcome)'
		AND j.name not in ('Check for blocking events' ,'AlertCAQWebQuotesStalled')
	ORDER BY
		rundatetime DESC
END		
GO
