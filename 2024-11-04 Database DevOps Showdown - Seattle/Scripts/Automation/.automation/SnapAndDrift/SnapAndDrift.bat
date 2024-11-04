@echo off
set "configFile=config-manual-run"
set /p configFile="Enter SQL Server source (config filename) or press enter to the default (%configFile%) "
set "sqlServerInstanceName=default"
set /p sqlServerInstanceName="Enter SQL Server instance name or press enter to use instance name (%sqlServerInstanceName%) "
set /p workingDir="Enter the Working Directory Path or press enter to use directory from script "
echo Access the path of the batch file.
pushd %~dp0
echo Run script SnapAndDrift.ps1.
pwsh -NoProfile -ExecutionPolicy Bypass -File ./SnapAndDrift.ps1 -configFile %configFile%.yaml -sqlServerInstanceName %sqlServerInstanceName% -workingDir %workingDir%
popd
pause