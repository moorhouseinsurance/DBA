IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recompile_prog]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[recompile_prog]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[recompile_prog]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v TABLE (RecID INT IDENTITY(1,1), spname sysname)
    -- retrieve the list of stored procedures
    INSERT INTO 
        @v(spname) 
    SELECT 
        '[' + s.[name] + '].[' + items.name + ']'     
    FROM 
        (SELECT sp.name, sp.schema_id, sp.is_ms_shipped FROM sys.procedures sp UNION SELECT so.name, so.SCHEMA_ID, so.is_ms_shipped FROM sys.objects so WHERE so.type_desc LIKE '%FUNCTION%') items
        INNER JOIN sys.schemas s ON s.schema_id = items.schema_id    
        WHERE is_ms_shipped = 0;

    -- counter variables
    DECLARE @cnt INT, @Tot INT;
    SELECT @cnt = 1;
    SELECT @Tot = COUNT(*) FROM @v;
    DECLARE @spname sysname
    -- start the loop
    WHILE @Cnt <= @Tot BEGIN    
        SELECT @spname = spname        
        FROM @v        
        WHERE RecID = @Cnt;
        --PRINT 'refreshing...' + @spname    
        BEGIN TRY        -- refresh the stored procedure        
            EXEC sp_refreshsqlmodule @spname    
        END TRY    
        BEGIN CATCH        
            PRINT 'Validation failed for : ' + @spname + ', Error:' + ERROR_MESSAGE();
        END CATCH    
        SET @Cnt = @cnt + 1;
    END;

END
GO

