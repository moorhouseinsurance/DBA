USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspBufferRowCountLongRunningCRUD]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------
-- Author		D.Hostler
-- Date			09 Oct 2017
-- Desc			Allows monitoring of long rnning insert progress prior to actual table insert
--------------------------------------------------

create PROCEDURE [dbo].[uspBufferRowCountLongRunningCRUD]
	 @DBName nvarchar(50)
	,@Tablename nvarchar(50)
AS
/*
	DECLARE
		 @DBName nvarchar(50)
		,@Tablename nvarchar(50
	exec [dbo].[uspBufferRowCountLongRunningCRUD] @DBName ,@Tablename
*/
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
		 @DBName 
		,@Tablename
		 ,SUM(sdobd.[row_count]) AS [BufferPoolRows]
		 ,SUM(sp.[rows]) AS [AllocatedRows]
		 ,COUNT(*) AS [DataPages]
	FROM 
		[sys].[dm_os_buffer_descriptors] AS  [sdobd]
		INNER JOIN  [sys].[allocation_units] [sau] ON [sau].[allocation_unit_id] = [sdobd].[allocation_unit_id]
		INNER JOIN  [sys].[partitions] [sp]
			ON  (sau.[type] = 1 AND sau.[container_id] = sp.[partition_id]) -- IN_ROW_DATA
			OR  (sau.[type] = 2 AND sau.[container_id] = sp.[hobt_id]) -- LOB_DATA
			OR  (sau.[type] = 3 AND sau.[container_id] = sp.[partition_id]) -- ROW_OVERFLOW_DATA
	WHERE   
		sdobd.[database_id] = DB_ID(@DBName)
		AND sdobd.[page_type] = N'DATA_PAGE'
		AND sp.[object_id] = OBJECT_id(@Tablename)
END                          

GO
