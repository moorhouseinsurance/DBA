USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[recompile_prog]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
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
