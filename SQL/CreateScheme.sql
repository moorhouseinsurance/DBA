--sqlcmd - S "MHGSQL01\TGSLTest" - i "CreateScheme.sql" -v databaseName = DBA path = "C:\Codebase\Development\GIT\DBA\SQL\Schema\"
use $(databaseName);
GO


:r $(path)dbo.DatabaseFileStatsTable.Table.sql
:r $(path)dbo.SubscriptionError.Table.sql

:r $(path)dbo.GetDBSize.UserDefinedFunction.sql
:r $(path)dbo.svfDBSize.UserDefinedFunction.sql

:r $(path)dbo.DatabaseBackupReport.StoredProcedure.sql
:r $(path)dbo.DatabaseFileStats.StoredProcedure.sql
:r $(path)dbo.DatabaseFileStatsxml.StoredProcedure.sql
:r $(path)dbo.DumpDataFromTable.StoredProcedure.sql
:r $(path)dbo.MissingIndexes.StoredProcedure.sql
:r $(path)dbo.PRC_WritereadFile.StoredProcedure.sql
:r $(path)dbo.recompile_prog.StoredProcedure.sql
:r $(path)dbo.RECREATE_TYPE.StoredProcedure.sql
:r $(path)dbo.SQLAgentJobLog.StoredProcedure.sql
:r $(path)dbo.uspBackup.StoredProcedure.sql
:r $(path)dbo.uspBackupCalculators.StoredProcedure.sql
:r $(path)dbo.uspBackupDatabase.StoredProcedure.sql
:r $(path)dbo.uspBackupRestoreCurrentReport.StoredProcedure.sql
:r $(path)dbo.uspCopyLiveDBToLocalDB.StoredProcedure.sql
:r $(path)dbo.uspCopyRemoteCalculatorsDBToLocalDB.StoredProcedure.sql
:r $(path)dbo.uspJobScheduleReport.StoredProcedure.sql
:r $(path)dbo.uspOKToBackup.StoredProcedure.sql
:r $(path)dbo.uspReportingServicesSubscriptionFailure.StoredProcedure.sql
:r $(path)dbo.uspRestoreCalculators.StoredProcedure.sql
:r $(path)dbo.uspSQLAgentJobIDFromReportName.StoredProcedure.sql
:r $(path)dbo.uspTablesByRowVolume.StoredProcedure.sql
:r $(path)dbo.uspTopWaitsSelect.StoredProcedure.sql
:r $(path)dbo.uspTrace.StoredProcedure.sql


:r $(path)dbo.DatabaseFileStatsTableType.UserDefinedTableType.sql
