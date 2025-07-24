param ($configFile, [bool] $snapOnly = 0, $sqlServerInstanceName, $suffixReport = "driftReport",$workingDir)
 
try {
    Import-Module powershell-yaml

    # Import functions in the Utils script.
    . $PSScriptRoot/../Utils/Utils.ps1

    $scriptName = $($MyInvocation.MyCommand.Name)
    Write-Information -Message "** Start script $scriptName **"

    if ($null -eq $workingDir) { $workingDir = Join-Path $PSScriptRoot "/../../" }
    Write-Information -Message "Working directory: $workingDir"
    
    $systemHostType = $env:SYSTEM_HOSTTYPE
    Write-Information -Message "System HostType: $systemHostType"

    # Settings from configuration file.
    $configFilePath = Join-Path $PSScriptRoot  "\..\$configFile"
    Write-Information -Message "Trying to open configuration file $configFilePath"

    if (Test-Path $configFilePath) {

        $config = Get-Content -Path $configFilePath  -ErrorAction Stop | ConvertFrom-Yaml -Ordered -ErrorAction Stop -Verbose
        Write-Information -Message "Get SqlServerInstance settings from configuration file."
        $sqlServerInstanceMachineName = $config.SqlServerInstance.MachineName
        $sqlServerInstanceUsername = $config.SqlServerInstance.Username
        $sqlServerInstancePassword = $config.SqlServerInstance.Password
        $sqlCompareLicenseKey = $config.SqlCompareLicenseKey
        Write-Information -Message "SqlServerInstance.ServerMachineName: $sqlServerInstanceMachineName"
        if ($pipelineRun) {
            Write-Information -Message "SqlServerInstance.UserName: ***"
            Write-Information -Message "SqlServerInstance.Password: ***"
        } else {
            Write-Information -Message "SqlServerInstance.UserName: $sqlServerInstanceUsername"
            Write-Information -Message "SqlServerInstance.Password: $sqlServerInstancePassword"
        }

        $instance = $config.SqlServerInstance.NamedInstances | Where-Object Name -eq $sqlServerInstanceName

        # Check if instance was found in config file.
        if ($null -eq $instance) {
            Write-Error -Message "Instance $sqlServerInstanceName was not found in configuration file."
            exit 1
        }

        Write-Information -Message "Found instance $sqlServerInstanceName in configuration file."
        $port = $instance.Port
        Write-Information -Message "Port: $port"

        Write-Information -Message "Start Snap & Drift for databases in configuration file."
        
        $driftedVersionedDatabases = 0
        foreach ($database in $config.Databases) {

            $databaseName = $database.Name
			Write-Information -Message "`$databaseName: $databaseName"

            if ($pipelineRun) {
                Write-Host "##[group]Database: $databaseName"
            }
            try {
                Write-Information -Message "*** Start Snap & Drift for $databaseName"
                # prepare other information for Flyway commands.
                $flywayProjectDirectory = Join-Path $workingDir $databaseName

                if ($databaseName -eq 'MySpecialdatabase') {
                    Write-Information -Message "$databaseName is excluded for now."
                    $versionedDatabase = $false
                }
                elseif (Test-Path -Path $flywayProjectDirectory) {
                    Write-Information -Message "$databaseName is versioned database, a drift will trigger a warning."
                    $versionedDatabase = $true
                }
                else {
                    Write-Information -Message "$databaseName is not a versioned database."
                    $versionedDatabase = $false
                }
                # Execute SQL Compare to create a snapshot the current database
                Write-Information -Message "Start SQL Compare snapshot for $databaseName"
                Write-Information -Message "Suffix snapshot of $databaseName with current timestamp: $(Get-Date -Format yyyyMMddHHmm)"
                $version = Get-Date -Format yyyyMMddHHmm

                $filename = $databaseName + "-$version"

                $databaseNameSnapshotPath = Join-Path $config.SnapShotReportPath "$databaseName"

                if (!(Test-Path -Path $databaseNameSnapshotPath)) {
                    New-Item $databaseNameSnapshotPath -ItemType Directory
                    Write-Information -Message "Created snapshot directory $databaseNameSnapshotPath"
                }

                $snapshotFilename = "$filename.snp"
                $snapshotPathAndFileName = Join-Path $databaseNameSnapshotPath $snapshotFilename
                Write-Information -Message "Snapshot will be stored as $snapshotPathAndFileName"

                $snapshotResult = New-SQLCompareSnapshotCmd -SnapshotPathAndFileName $snapshotPathAndFileName -TargetHost $sqlServerInstanceMachineName -Port $port -DatabaseName $databaseName -User $sqlServerInstanceUsername -Password $sqlServerInstancePassword -SqlCompareLicenseKey $sqlCompareLicenseKey

                IF ($LASTEXITCODE -eq 0) {
                    Write-Information -Message "Finished SQL Compare snapshot for $databaseName"
                }
                else {
                    Write-Warning "Snapshot of $databaseName failed, output of SQL Compare:"
                    Write-Warning $snapshotResult
                    Write-Warning "Exit code: $LASTEXITCODE"
                    throw "Snapshot creation failed"
                }

                # This script can also be used to make a snapshot only, $snapOnly = $true
                if ($snapOnly) {
                    Write-Information -Message "Snapshot only for database $databaseName"
                    Write-Information -Message "*** Finished create Snap & Drift for database $databaseName"
                }
                else {

                    # Select latest snapshot in the $databaseNameSnapshotPath, but not the just created snapshot
                    $previousSnapshot = Get-ChildItem -path $databaseNameSnapshotPath -exclude $snapshotFileName | Select-Object -last 1
                    $previousSnapshotPathAndFileName = Convert-Path $previousSnapshot

                    Write-Information -Message "Testing path location previous snapshot: $previousSnapshot"
                    if (Test-Path -Path $previousSnapshotPathAndFileName) {

                        # Execute SQL Compare and then verify the result via the exit code.
                        Write-Information -Message "Start SQL Compare report for $databaseName"

                        $driftReportPath = $config.driftReportPath

                        if (!(Test-Path -Path $driftReportPath)) {
                            New-Item $driftReportPath -ItemType Directory
                            Write-Information -Message "Created snapshot directory $driftReportPath"
                        }

                        $driftReportPathAndFileName = Join-Path $driftReportPath "$filename-$suffixReport.html"
                    
                        Write-Information -Message "Results will be stored as $driftReportPathAndFileName"
    
                        $compareResult = New-SQLCompareReportCmd -Snapshot1PathAndFileName $snapshotPathAndFileName -Snapshot2PathAndFileName $previousSnapshotPathAndFileName -ReportPathAndFileName $driftReportPathAndFileName -SqlCompareLicenseKey $sqlCompareLicenseKey
    
                        IF ($LASTEXITCODE -eq 0) {
                            Write-Information "No drift detected"
                            Write-Information "Deleting snapshot $snapshotPathAndFileName"
                            Remove-Item -Path $snapshotPathAndFileName
                            Write-Information "Deleting SQL Compare Report: $driftReportPathAndFileName"
                            Remove-Item -Path $driftReportPathAndFileName
                        }
                        else {
                            if ($versionedDatabase) {
                                if ($systemHostType -eq "build") {
                                     Write-Host "##vso[artifact.upload artifactname=$databaseName]$driftReportPathAndFileName"
                                }
                                Write-warning "$databaseName is drifted, output of SQL Compare:" -WithLog $true
                                ++$driftedVersionedDatabases
                            }
                            else {
                                Write-Information "$databaseName is drifted, output of SQL Compare:"
                            }
                            Write-Information $compareResult
                            Write-Information "Exit code: $LASTEXITCODE"
                        }
        
                        Write-Information -Message "*** Finished create Snap & Drift for database $databaseName"

                    }
                    else {
                        Write-Warning -Message "No previous snapshot found, no drift detection for database $databaseName possible"
                        Write-Warning -Message "Kept the just created snapshot ($snapshotPathAndFileName) as the latest stable"
                    }

                }
            }
            catch {
                Write-Error -Message "Create Snap & Drift failed for database $databaseName"     
                $_
            }
            if ($pipelineRun) {
                Write-Host "##[endgroup]"
            }
        }
    }
    else {
        Write-Error -Message "Config file not found"
    }
    Write-Information -Message "$driftedVersionedDatabases database(s) drifted."
    if ($pipelineRun) {
        Write-Information "##vso[task.setvariable variable=driftedVersionedDatabases;]$driftedVersionedDatabases"
        if ($driftedVersionedDatabases -gt 0) {
            Write-Host "##vso[build.addbuildtag]DatabaseDrifted"
            Write-Information "##vso[task.complete result=SucceededWithIssues;]"
        }
    }
}
catch {
    Write-Error -Message "Script $scriptName failed."     
    $_
}
finally {
    Write-Information -Message "** Finished script $scriptName **"
}
