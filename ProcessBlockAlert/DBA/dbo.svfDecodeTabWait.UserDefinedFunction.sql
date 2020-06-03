USE [DBA]
GO

/****** Object:  UserDefinedFunction [dbo].[svfDecodeTabWait]    Script Date: 03/06/2020 10:41:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		D. Hostler
-- Create date: 06 Jan 2020
-- Description:	Decodes TAB: Waits
-- =============================================
CREATE FUNCTION [dbo].[svfDecodeTabWait]
(
	@TabWait varchar(100)
)
RETURNS varchar(100)
AS
/*
	DECLARE @TabWait varchar(100) = 'TAB: 5:200907262:0'
		SELECT [dbo].[svfDecodeTabWait] (@TabWait)
*/
BEGIN
	-- Declare the return variable here
	DECLARE @TabWaitName varchar(100)
	SET @TabWait = REPLACE(@TabWait,'Tab: ','')

	SET @TabWaitName = (SELECT OBJECT_NAME([T].[2],[T].[1]) FROM  [Shared].[dbo].[tvfCSVSplitCols30bigint](@TabWait ,':') AS [T])

	-- Return the result of the function
	RETURN @TabWaitName

END

GO


