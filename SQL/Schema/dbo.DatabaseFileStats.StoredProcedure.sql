USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[DatabaseFileStats]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Database File Stats.Added 10pct to reserved allocation to estimate Backup file(Data +log) size
--======================================
CREATE PROCEDURE [dbo].[DatabaseFileStats]
	 @Databases varchar(255)
AS
/*
	DECLARE @Databases varchar(255) =  'Transactor_Live,Calculators,Product,STAGINGTABLES'
 
	exec [dbo].[DatabaseFileStats] @Databases 


*/
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @ResultsXML xml 
	exec [dbo].[DatabaseFileStatsxml] @Databases ,@ResultsXML Output

	DECLARE  @handle INT  ,@PrepareXmlStatus INT  
	EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @ResultsXML  
	SELECT  * FROM  OPENXML(@handle, '/ResultSets/ResultSet', 2) WITH [DatabaseFileStatsTable]
	
END


GO
