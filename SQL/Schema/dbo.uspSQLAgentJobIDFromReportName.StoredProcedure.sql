USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspSQLAgentJobIDFromReportName]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
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
