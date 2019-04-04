IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspSQLAgentJobIDFromReportName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspSQLAgentJobIDFromReportName]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspSQLAgentJobIDFromReportName]
	@Reportname varchar(255)
AS
/*

USE [DBA]
GO

DECLARE @RC int
DECLARE @Reportname varchar(255) = 'NB Docs Sent'

-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[uspSQLAgentJobIDFromReportName] 
   @Reportname
GO


*/
BEGIN
	SELECT
		[c].[Name] AS [ReportName]
		,[RS].[ScheduleID] AS [JOB_NAME]
		,[S].[Description]
		,[S].LastStatus
		,[S].LastRunTime
	FROM
		[ReportServer]..[Catalog] AS [C]
		JOIN [ReportServer]..[Subscriptions] [S] ON [C].[ItemID] = [S].[Report_OID]
		JOIN [ReportServer]..[ReportSchedule] [RS] ON [C].[ItemID] = [RS].[ReportID]
		AND [RS].[SubscriptionID] = [S].[SubscriptionID]
	WHERE
		[c].[Name] = @ReportName
END

GO

