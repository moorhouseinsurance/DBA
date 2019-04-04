IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspReportingServicesSubscriptionFailure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspReportingServicesSubscriptionFailure]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Created by DHostler 
-- Create date: 17-Dec-2013
-- Description: Detects failed reports
-- =============================================

CREATE PROC [dbo].[uspReportingServicesSubscriptionFailure]

AS

/* 

EXEC [dbo].[uspReportingServicesSubscriptionFailure]

*/ 

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE @Datetime datetime = GETDATE()
	DECLARE @Count int = 0
	
	INSERT INTO [SubscriptionError] 
	SELECT 
		 [S].[SubscriptionID]
		,[C].[Name]
		,[S].[Description]
		,[S].[LastStatus]
		,[S].[LastRunTime]
		,[S].[DeliveryExtension] 
		
	FROM 
		[ReportServer].[dbo].[Subscriptions] AS [S]
		LEFT OUTER JOIN [ReportServer].[dbo].[Catalog] AS [C] ON [C].[ItemID] = [S].[Report_OID]	
	WHERE 
		[S].[LastStatus] Like 'Failure%' 
		AND [S].[LastRunTime] BETWEEN dateadd(mi,-15,@Datetime) AND @Datetime
		AND [S].[SubscriptionID] != 'BD9DA830-A327-4FA5-BD38-44EEDD0CC650' --Ghost Subscription

	SET @Count = @@ROWCOUNT
	IF @Count != 0
	BEGIN			
		DECLARE @NewLineChar AS nCHAR(2) = CHAR(13) + CHAR(10)
		DECLARE @bodytext nvarchar(4000) = ''
			
		SELECT 
			@bodytext =  @bodytext
			+'The Subscription : '
			+[S].[Description] + @NewLineChar
			+'On Report : '
			+[S].[Name] + @NewLineChar
			+'Failed with error message : '
			+[S].[LastStatus] + @NewLineChar
			+'At : '
			+CAST([S].[LastRunTime] AS varchar) + @NewLineChar
			 +'==================================================================='+@NewLineChar+@NewLineChar
		FROM
			[dbo].[SubscriptionError] AS [S]
		WHERE
			 [S].[LastRunTime] BETWEEN dateadd(mi,-15,@Datetime) AND @Datetime		
			
		EXEC MSDB.dbo.sp_send_dbmail @profile_name='SQLAgentAlerts',
		@recipients='PriorityResponse@moorhouseinsurance.co.uk',
		@subject='Report Subsription Failure',
		@body= @bodytext
	
		RAISERROR (100009,16,0) WITH LOG
	END 
END


GO

