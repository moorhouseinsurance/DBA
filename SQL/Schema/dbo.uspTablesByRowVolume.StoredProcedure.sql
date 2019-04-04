IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTablesByRowVolume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspTablesByRowVolume]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Devlin Hostler
-- Create date: 06 Jan 2017
-- Description:	List tables with most rows
-- =============================================

CREATE PROCEDURE [dbo].[uspTablesByRowVolume]
	 @DatabaseName varchar(255) = null
	,@TopTenAll bit = 0
AS
/*
	DECLARE	@DatabaseName varchar(255) = 'Transactor_Live'
	,@TopTenAll bit = 1
	EXEC [dbo].[uspTablesByRowVolume] @DatabaseName
*/
BEGIN
	DECLARE @SQL varchar(8000) = ' USE [?] 
	SELECT DB_NAME();
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT Top 10    
		OBJECT_SCHEMA_NAME(OBJECT_ID) AS [Schema],      
		OBJECT_NAME(OBJECT_ID) AS [TableName],
		SUM([P].[row_count]) AS [RowCount]
	FROM 
		[sys].[dm_db_partition_stats] AS [P]
	WHERE 
		[index_id] IN (0,1)
	GROUP BY 
		OBJECT_ID
	HAVING 
		SUM([P].[row_count]) > 0
	ORDER BY
		 [Schema],[RowCount] DESC'

	IF @TopTenAll = 0
	BEGIN
		SET @SQL = REPLACE(@sql,'Top 10','')
		SET @SQL = REPLACE(@sql,'?',@DatabaseName)
		exec (@SQL);
	END
	ELSE
	BEGIN
		SET @SQL =  REPLACE(@sql,'[Schema],[RowCount]','[RowCount]')
		EXEC sp_MSforeachdb @SQL
	END
END

GO

