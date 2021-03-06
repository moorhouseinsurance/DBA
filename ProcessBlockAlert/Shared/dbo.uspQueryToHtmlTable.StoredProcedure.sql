
--======================================
--Author	D. Hostler
--Date		23 Jan 2020
--Desc		Format Query results as HTML table string (amended to allow CTE queries)
--			--https://stackoverflow.com/questions/7070053/convert-a-sql-query-result-table-to-an-html-table-for-email
--======================================

CREATE PROC [dbo].[uspQueryToHtmlTable] 
(
  @query nvarchar(MAX), --A query to turn into HTML format. It should not include an ORDER BY clause.
  @orderBy nvarchar(MAX) = NULL, --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
  @html nvarchar(MAX) = NULL OUTPUT --The HTML output of the procedure.

)
AS
/*
DECLARE  @html nvarchar(MAX)
		,@query nvarchar(MAX) = 'SELECT * FROM BlockedProcess'
EXEC spQueryToHtmlTable @html = @html OUTPUT,  @query = @query;

select @html

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Exchange Server',
    @recipients = 'DHostler@Constructaquote.com;',
    @subject = 'Blocking processes',
    @body = @html,
    @body_format = 'HTML',
    @query_no_truncate = 1,
    @attach_query_result_as_file = 0;


*/
BEGIN   
  SET NOCOUNT ON;

  IF @orderBy IS NULL BEGIN
    SET @orderBy = ''  
  END

  SET @orderBy = REPLACE(@orderBy, '''', '''''');

  IF @Query NOT LIKE ';%'
  BEGIN
	SET @query =   'SELECT * INTO #dynSql FROM (' + @query + ') sub;'
  END

  DECLARE @realQuery nvarchar(MAX) = '
	IF OBJECT_ID(''tempdb..#dynSql'') IS NOT NULL DROP TABLE #dynSql

    DECLARE @headerRow nvarchar(MAX);
    DECLARE @cols nvarchar(MAX);    

    ' + @query + '

    SELECT @cols = COALESCE(@cols + '', '''''''', '', '''') + ''['' + name + ''] AS ''''td''''''
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @cols = ''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @orderBy + ' FOR XML PATH(''''tr''''), ELEMENTS XSINIL) AS nvarchar(max))''    

    EXEC sys.sp_executesql @cols, N''@html nvarchar(MAX) OUTPUT'', @html=@html OUTPUT

    SELECT @headerRow = COALESCE(@headerRow + '''', '''') + ''<th>'' + name + ''</th>'' 
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @headerRow = ''<tr>'' + @headerRow + ''</tr>'';

    SET @html = ''<table class="box-table" style="width:100%" >'' + @headerRow + @html + ''</table>'';    
    ';

  EXEC sys.sp_executesql @realQuery, N'@html nvarchar(MAX) OUTPUT', @html=@html OUTPUT
END
