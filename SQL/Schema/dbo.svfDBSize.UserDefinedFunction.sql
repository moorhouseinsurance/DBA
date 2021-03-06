USE [DBA]
GO
/****** Object:  UserDefinedFunction [dbo].[svfDBSize]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Estimate Uncompressed Backup database
--======================================
CREATE FUNCTION [dbo].[svfDBSize] 
(
    @db_name NVARCHAR(100)
)
RETURNS INT
AS
/*

	DECLARE @db_name NVARCHAR(100) = 'Transactor_Live'
	SELECT [dbo].[svfDBSize] (@db_name)

*/
BEGIN
	DECLARE @Size int
	SELECT @Size =
		CAST(SUM(size) * 8 / 1024 AS DECIMAL(8,2)) *1.015
	FROM 
		sys.master_files WITH(NOWAIT)
  WHERE 
		database_id = DB_ID(@db_name)
  GROUP BY database_id

  RETURN @Size
END

GO
