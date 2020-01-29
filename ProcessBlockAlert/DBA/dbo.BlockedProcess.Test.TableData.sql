TRUNCATE TABLE [dbo].[BlockedProcess]

INSERT INTO [dbo].[BlockedProcess] 
([PolledDateTime]
,[PDBID],[PSPID],[PName],[BSPID],[BName],[HeadBlocker])

VALUES
 ('01 Jan 2020',1,3,'Head',2,'Blocker',0)
,('01 Jan 2020',1,4,'Head',3,'Blocker',0)
,('01 Jan 2020',1,5,'Head',2,'Blocker',0)
,('01 Jan 2020',1,6,'Head',1,'Blocker',1)
,('01 Jan 2020',1,7,'Head',3,'Blocker',0)
,('01 Jan 2020',1,8,'Head',3,'Blocker',0)
,('01 Jan 2020',1,2,'Head',1,'Blocker',0)
,('01 Jan 2020',1,9,'Head',2,'Blocker',0)
,('01 Jan 2020',1,10,'Head',6,'Blocker',0)
,('01 Jan 2020',1,22,'Head',23,'Blocker',1)

   
SELECT [PolledDateTime],[PDBID],[PSPID],[PName],[BSPID],[BName],[HeadBlocker]
FROM [dbo].[BlockedProcess]
