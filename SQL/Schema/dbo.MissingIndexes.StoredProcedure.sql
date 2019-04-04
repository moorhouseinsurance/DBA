IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MissingIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[MissingIndexes]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

---------------------------------
--Author:	D,Hostler
--Date:		04 Oct 2018
--Desc		Create Index script
--Ref		https://blog.sqlauthority.com/2011/01/03/sql-server-2008-missing-index-script-download/
---------------------------------------

CREATE PROCEDURE [dbo].[MissingIndexes] 
	@DatabaseName varchar(255)
AS
/*

	DECLARE @DatabaseName varchar(255) = 'Calculators'
	exec [dbo].[MissingIndexes] @DatabaseName

*/
BEGIN
	SELECT TOP 25
		DB_Name(dm_mid.database_id) AS DatabaseName,
		dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
		dm_migs.last_user_seek AS Last_User_Seek,
		OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
		'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
		+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
		+ CASE
		WHEN dm_mid.equality_columns IS NOT NULL
		AND dm_mid.inequality_columns IS NOT NULL THEN '_'
		ELSE ''
		END
		+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
		+ ']'
		+ ' ON ' + dm_mid.statement
		+ ' (' + ISNULL (dm_mid.equality_columns,'')
		+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
		IS NOT NULL THEN ',' ELSE
		'' END
		+ ISNULL (dm_mid.inequality_columns, '')
		+ ')'
		+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
	FROM 
		sys.dm_db_missing_index_groups dm_mig
		INNER JOIN sys.dm_db_missing_index_group_stats dm_migs ON dm_migs.group_handle = dm_mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details dm_mid ON dm_mig.index_handle = dm_mid.index_handle
	WHERE
		dm_mid.database_ID = DB_ID(@DatabaseName)
	ORDER BY 
		Avg_Estimated_Impact DESC
END

GO

