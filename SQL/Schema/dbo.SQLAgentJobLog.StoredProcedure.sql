IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SQLAgentJobLog]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SQLAgentJobLog]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Devlin Hostler
-- Create date: 06 Jan 2017
-- Description:	Populate Dialler table
-- EXEC [AdaptiveCampaign].[uspDiallerData]  
-- =============================================

CREATE PROCEDURE [dbo].[SQLAgentJobLog]
	@JobName nvarchar(50)	
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
		and j.name = @JobName
		and step_name = '(Job outcome)'
	ORDER BY
		rundatetime DESC
END		
GO

