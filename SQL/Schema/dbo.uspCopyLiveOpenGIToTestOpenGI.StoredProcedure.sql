USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspCopyLiveOpenGIToTestOpenGI]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Devlin Hostler
-- Create date: 20 Jan 2020
-- Description:	Backs up and restores OpenGi database
-- =============================================
CREATE PROCEDURE [dbo].[uspCopyLiveOpenGIToTestOpenGI]

AS
/*

	EXEC [dbo].[uspCopyLiveOpenGIToTestOpenGI]

*/
BEGIN

	EXEC [MHGSQL01\Infocentre].[DBA].[dbo].[uspBackupOpenGI]

	ALTER DATABASE [OpenGI] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	RESTORE DATABASE [OpenGI] FROM  DISK = N'L:\sql_backups\INFOCENTRE\OpenGIToTest.bak' WITH FILE = 1, NOUNLOAD,  REPLACE,  STATS = 10,
		MOVE 'OpenGI_mdf0' TO N'S:\SQL_Data\TGSLTest\OpenGI.mdf',
		MOVE 'OpenGI_ldf0' TO N'L:\SQL_Logs\TGSLTest\OpenGI.ldf';

	ALTER DATABASE [OpenGI] SET MULTI_USER WITH ROLLBACK IMMEDIATE

END

GO
