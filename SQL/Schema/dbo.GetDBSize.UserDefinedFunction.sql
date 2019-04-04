IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetDBSize]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GetDBSize]
GO

SET ANSI_NULLS ON
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

