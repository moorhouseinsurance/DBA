IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RECREATE_TYPE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[RECREATE_TYPE]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RECREATE_TYPE]
    @schema     VARCHAR(100),       -- the schema name for the existing type
    @typ_nme    VARCHAR(128),       -- the type-name (without schema name)
    @sql        VARCHAR(MAX)        -- the SQL to create a type WITHOUT the "CREATE TYPE schema.typename" part
AS DECLARE
    @scid       BIGINT,
    @typ_id     BIGINT,
    @temp_nme   VARCHAR(1000),
    @msg        VARCHAR(200)
BEGIN
/*


USE [DBA]
GO

DECLARE @RC int
DECLARE @schema varchar(100)
DECLARE @typ_nme varchar(128)
DECLARE @sql varchar(max)

-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[RECREATE_TYPE] 
   @schema
  ,@typ_nme
  ,@sql
GO


*/
    -- find the existing type by schema and name
    SELECT @scid = [SCHEMA_ID] FROM sys.schemas WHERE UPPER(name) = UPPER(@schema);
    IF (@scid IS NULL) BEGIN
        SET @msg = 'Schema ''' + @schema + ''' not found.';
        RAISERROR (@msg, 1, 0);
    END;
    SELECT @typ_id = system_type_id FROM sys.types WHERE UPPER(name) = UPPER(@typ_nme);
    SET @temp_nme = @typ_nme + '_rcrt'; -- temporary name for the existing type

    -- if the type-to-be-recreated actually exists, then rename it (give it a temporary name)
    -- if it doesn't exist, then that's OK, too.
    IF (@typ_id IS NOT NULL) BEGIN
        exec sp_rename @objname=@typ_nme, @newname= @temp_nme, @objtype='USERDATATYPE'
    END;    

    -- now create the new type
    SET @sql = 'CREATE TYPE ' + @schema + '.' + @typ_nme + ' ' + @sql;
    exec sp_sqlexec @sql;

    -- if we are RE-creating a type (as opposed to just creating a brand-spanking-new type)...
    IF (@typ_id IS NOT NULL) BEGIN
        exec recompile_prog;    -- then recompile all stored procs (that may have used the type)
        exec sp_droptype @typename=@temp_nme;   -- and drop the temporary type which is now no longer referenced
    END;    
END


GO

