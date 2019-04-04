IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRC_WritereadFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PRC_WritereadFile]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[PRC_WritereadFile] (
        @FileMode INT -- Recreate = 0 or Append Mode 1
       ,@Path NVARCHAR(1000)
       ,@AsFileNAme NVARCHAR(500)
       ,@FileBody NVARCHAR(MAX)   
       )
    AS
        DECLARE @OLEResult INT
        DECLARE @FS INT
        DECLARE @FileID INT
        DECLARE @hr INT
        DECLARE @FullFileName NVARCHAR(1500) = @Path + @AsFileNAme
     
        -- Create Object
        EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUTPUT
        IF @OLEResult <> 0 BEGIN
            PRINT 'Scripting.FileSystemObject'
            GOTO Error_Handler
        END    
 
        IF @FileMode = 0 BEGIN  -- Create
            EXECUTE @OLEResult = sp_OAMethod @FS,'CreateTextFile',@FileID OUTPUT, @FullFileName
            IF @OLEResult <> 0 BEGIN
                PRINT 'CreateTextFile'
                GOTO Error_Handler
            END
        END ELSE BEGIN          -- Append
            EXECUTE @OLEResult = sp_OAMethod @FS,'OpenTextFile',@FileID OUTPUT, @FullFileName, 8, 0 -- 8- forappending
            IF @OLEResult <> 0 BEGIN
                PRINT 'OpenTextFile'
                GOTO Error_Handler
            END            
        END
     
        EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', NULL, @FileBody
        IF @OLEResult <> 0 BEGIN
            PRINT 'WriteLine'
            GOTO Error_Handler
        END     
 
        EXECUTE @OLEResult = sp_OAMethod @FileID,'Close'
        IF @OLEResult <> 0 BEGIN
            PRINT 'Close'
            GOTO Error_Handler
        END
     
        EXECUTE sp_OADestroy @FS
        EXECUTE sp_OADestroy @FileID
     
        GOTO Done
 
        Error_Handler:
            DECLARE @source varchar(30), @desc varchar (200)       
            EXEC @hr = sp_OAGetErrorInfo null, @source OUT, @desc OUT
            PRINT '*** ERROR ***'
            SELECT OLEResult = @OLEResult, hr = CONVERT (binary(4), @hr), source = @source, description = @desc
 
       Done:
    
GO

