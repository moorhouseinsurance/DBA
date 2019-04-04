IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspOKToBackup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspOKToBackup]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--======================================
--Author	D. Hostler
--Date		27 Mar 2019
--Desc		Check if enough space to Backup database
--======================================
CREATE PROCEDURE [dbo].[uspOKToBackup] 
     @db_name NVARCHAR(100)
	,@DriveLetter  VARCHAR (5) 
	,@OKToBackup bit out
	,@BackUpSizeMb int out
	,@FreeDriveSpaceMb int out

AS
/*

	DECLARE	 @db_name NVARCHAR(100) = 'Transactor_Live'
			,@DriveLetter  VARCHAR (5) = 'C'
			,@OKToBackup bit
			,@BackUpSizeMb int
			,@FreeDriveSpaceMb int 

	exec [dbo].[uspOKToBackup] @db_name ,@DriveLetter ,@OKToBackup out ,@BackUpSizeMb out ,@FreeDriveSpaceMb out

	select @OKToBackup ,@BackUpSizeMb ,@FreeDriveSpaceMb

*/
BEGIN
	SET NOCOUNT ON 
	SET @BackUpSizeMb = [dbo].[svfDBSize] (@db_name)

	DECLARE @FixedDrives TABLE ([Drive] VARCHAR (5), [MBFree] DECIMAL (8, 2))
	INSERT INTO @FixedDrives ([Drive],[MBFree])	EXEC xp_fixeddrives
	
	SELECT 
		 @OKToBackup = CASE WHEN @BackUpSizeMb > [MBFree] THEN 0 ELSE 1 END
		,@FreeDriveSpaceMb = [MBFree]
	FROM 
		@FixedDrives 
	WHERE 
		[Drive] = @DriveLetter

END

GO

