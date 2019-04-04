echo off
setlocal enabledelayedexpansion
SET Database=DBA
SET InstanceName="MHGSQL01\TGSLTest"
SET SchemeSQLPath=C:\Codebase\Development\GIT\DBA\SQL\

SET PathData=%SchemeSQLPath%Data\
SET PathSchema=%SchemeSQLPath%Schema\

sqlcmd -S%InstanceName% -i "%SchemeSQLPath%CreateScheme.sql" -v databaseName = %Database% path = "%PathSchema%"

PUSHD %PathData%

for %%i in (*.txt) do (
SET FileName=%%~i
SET SchemeObjectName=!FileName:.Table.txt=!
bcp %Database%.!SchemeObjectName! in !FileName! -n -T -E -S%InstanceName%
)
POPD
