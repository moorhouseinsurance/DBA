USE [DBA]
GO

/****** Object:  UserDefinedFunction [dbo].[svfDecodeProgram]    Script Date: 03/06/2020 10:41:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		D. Hostler
-- Create date: 03 Jun 2020
-- Description:	Decodes Program
-- =============================================
CREATE FUNCTION [dbo].[svfDecodeProgram]
(
	@Program varchar(250)
)
RETURNS varchar(250)
AS
/*
	DECLARE @Program varchar(250) = 'SQLAgent - TSQL JobStep (Job 0x840004998670B841AF2E1D868D9EEF15 : Step 1)   ' 
	SELECT [dbo].[svfDecodeProgram] (@Program)
*/
BEGIN
	DECLARE @ProgramName varchar(250) = @Program
	IF @Program  Like 'SQLAgent%' 
	BEGIN
		DECLARE @JobID uniqueidentifier
		DECLARE @JOB varchar(34) = SUBSTRING(@Program,CHARINDEX('0x',@Program,1),34)
		SET @JobID = Cast(Convert(binary(16), @JOB, 1) AS uniqueidentifier)
		SELECT @ProgramName = [name] from msdb..sysjobs where [job_id] = @JobID;
		SET @ProgramName = REPLACE(@Program,@JOB,@ProgramName)
	END
	RETURN @ProgramName

END

GO


