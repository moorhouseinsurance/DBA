USE [DBA]
GO
/****** Object:  UserDefinedFunction [dbo].[GetDBSize]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetDBSize] 
(
    @db_name NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN

  SELECT 
        database_name = DB_NAME(database_id)
       ,total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2)) *1.015
  FROM sys.master_files WITH(NOWAIT)
  WHERE database_id = DB_ID(@db_name)
      OR @db_name IS NULL
  GROUP BY database_id
GO
