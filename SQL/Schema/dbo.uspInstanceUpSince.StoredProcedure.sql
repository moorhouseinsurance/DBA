USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspInstanceUpSince]    Script Date: 29/01/2020 10:46:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--======================================
--Author	D. Hostler
--Date		06 Nov 2019
--Desc		Instance up dates
--======================================
CREATE PROCEDURE [dbo].[uspInstanceUpSince]

AS

/*
EXECUTE [dbo].[uspInstanceUpSince]
*/
BEGIN
	SELECT 'MHGSQL01\infocentre' , sqlserver_start_time FROM [MHGSQL01\infocentre].[Master].sys.dm_os_sys_info
	UNION SELECT 'MHGSQL01\TGSLTest' , sqlserver_start_time FROM [MHGSQL01\TGSLTEST].[Master].sys.dm_os_sys_info
	UNION SELECT 'MHGSQL01\TGSL' , sqlserver_start_time FROM [MHGSQL01\TGSL].[Master].sys.dm_os_sys_info
	UNION SELECT 'MGL-dw' , sqlserver_start_time FROM [mgl-dw].[Master].sys.dm_os_sys_info
	UNION SELECT 'MHGSQL02\WEB_LIVE' , sqlserver_start_time FROM [MHGSQL02\WEB_LIVE].[Master].sys.dm_os_sys_info
	--UNION SELECT 'MHGSQL02\WEB_TEST' , sqlserver_start_time FROM [MHGSQL02\WEB_TEST].[Master].sys.dm_os_sys_info
	--UNION SELECT 'MHGMICCSQL01' , sqlserver_start_time FROM [MHGSQL02\WEB_TEST].[Master].sys.dm_os_sys_info
	--UNION SELECT '10.1.10.200\AMCR' , sqlserver_start_time FROM [10.1.10.200\AMCR].[Master].sys.dm_os_sys_info
END







GO
