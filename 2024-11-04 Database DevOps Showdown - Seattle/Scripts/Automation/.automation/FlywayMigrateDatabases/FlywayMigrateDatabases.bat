@echo off
set "configFile=config-manual-run"
set /p configFile="Enter SQL Server source (config filename) or press enter to the default when running manual (%configFile%) "
set "sqlServerInstanceName=Bartender"
set /p sqlServerInstanceName="Enter SQL Server instance name or press enter to use instance name Bartender "
set /p workingDir="Enter the Working Directory Path or press enter to use directory from script "
echo Access the path of the batch file.
pushd %~dp0
echo Run script FlywayMigrateDatabases.ps1.
pwsh -NoProfile -ExecutionPolicy Bypass -File ./FlywayMigrateDatabases.ps1 -configFile %configFile%.yaml -sqlServerInstanceName %sqlServerInstanceName% -workingDir %workingDir%
popd
pause

