#********************************************
#****** Script Flyway Migrate Databases *****
#********************************************
param ($configFile, $sqlServerInstanceName, $workingDir=$null) 
try {
    Import-Module powershell-yaml
    # Import functions in the Utils script.
    . $PSScriptRoot/../Utils/Utils.ps1

    $scriptName = $($MyInvocation.MyCommand.Name)
    Write-Information -Message "** Start script $scriptName **"

    if ($null -eq $workingDir) { $workingDir = Join-Path $PSScriptRoot "/../../" }
    Write-Information -Message "Working directory: $workingDir"
   
    $configFilePath = Join-Path $PSScriptRoot "\..\$configFile"

    # Settings from configuration file.
    Write-Information -Message "Trying to open configuration file $configFile"

    if (!(Test-Path $configFilePath)) {
        Write-Error -Message "Config file ($configFilePath) not found" 
        if ($configFile -like "*config-manual-run*") {
            Write-Error -Message "Does config-manual-run.yaml exist? If not create one from the existing .yamls `r`nE.g. copy PMC01.yaml to config-manual-run.yaml"
        }
        throw "Config file not found exception"
        
    }
    else {
        $config = Read-YamlFile -filePath $configFilePath
    } 

    Write-Information -Message "Get settings from configuration file."
    $sqlServerInstanceMachineName = $config.SqlServerInstance.MachineName
    $sqlServerInstanceUsername = $config.SqlServerInstance.Username
    $sqlServerInstancePassword = $config.SqlServerInstance.Password
    Write-Information -Message "SqlServerInstance.MachineName: $sqlServerInstanceMachineName"
    if ($pipelineRun) {
        Write-Information -Message "SqlServerInstance.UserName: ***"
        Write-Information -Message "SqlServerInstance.Password: ***"
    }
    else {
        Write-Information -Message "SqlServerInstance.UserName: $sqlServerInstanceUsername"
        Write-Information -Message "SqlServerInstance.Password: $sqlServerInstancePassword"
    }

    $instance = $config.SqlServerInstance.NamedInstances | Where-Object Name -eq $sqlServerInstanceName

    # Check if instance was found in config file.
    if ($null -eq $instance) {
        Write-Error -Message "Instance $sqlServerInstanceName was not found in configuration file."
        throw "SQL instance not found exception"
    }

    Write-Information -Message "Found instance $sqlServerInstanceName in configuration file."
    $port = $instance.Port
    Write-Information -Message "Port: $port"

    $migrationRun = 1
    $runMigrations = $true # this variable as a gate to run the migrations, and can be set to false to prevent looping
    while ($runMigrations) {
        $migrationErrors = 0
        Write-Information -Message "Start Flyway migration for databases in configuration file, migration run $migrationRun"
        foreach ( $database in $config.Databases) {
            try {
                $databaseName = $database.Name
                $flywayFolderName = $database.FlywayFolderName
                Write-Information -Message "databaseName: $databaseName and flywayFolderName: $flywayFolderName "

                if ($pipelineRun) {
                    Write-Host "##[group]Database: $databaseName"
                }
                Write-Information -Message "** Start Flyway migration for database $databaseName with flywayFolderName: $flywayFolderName **"
            
                $url = "jdbc:sqlserver://$($sqlServerInstanceMachineName):$port;encrypt=false;databaseName=$databaseName;trustServerCertificate=true"

                # prepare other information for Flyway commands.
                $flywayProjectDirectory = Join-Path $workingDir $flywayFolderName

                if (-not [string]::IsNullOrWhiteSpace($flywayFolderName) -and (Test-Path -Path $flywayProjectDirectory)) {

                    # Parameters for Flyway command.
                    $params = 
                    'info', 
                    "-workingDirectory=$flywayProjectDirectory",
                    "-url=$url",
                    "-user=$sqlServerInstanceUsername",
                    "-password=$sqlServerInstancePassword",
                    '-skipCheckForUpdate',
                    '-outOfOrder=true',
                    '-outputType=json'

                    if ($pipelineRun) {
                        Write-Information -Message "Execute Flyway info command"
                    }
                    else {
                        Write-Information -Message "Execute Flyway info command with following parameters:"
                        $params
                    }

                    $flywayInfoJson = & 'flyway' @params

                    if ($null -eq $flywayInfoJson) {
                        throw "Output of Flyway info command is null."
                    }

                    $flywayInfo = $flywayInfoJson | ConvertFrom-Json -Depth 100

                    if ($null -ne $flywayInfo.error) {
                        Write-Error -Message "Flyway info command failed:"
                        $flywayInfoJson
                        throw $flywayInfo.error.message
                    }

                    if ($null -eq $flywayInfo.migrations) {
                        Write-Information -Message "No migrations found in output of Flyway info command."
                        continue 
                    }

                    $pendingMigrations = $flywayInfo.migrations | Where-Object { $_.state -eq 'Pending' }
                    if ($pendingMigrations.Count -eq 0) {
                        Write-Information -Message "No pending migrations found in output of Flyway info command."
                        continue
                    }

                    Write-Information -Message "Pending migrations found in output of Flyway info command."
                    Write-Information -Message "Showing output of Flyway info command (hiding migrations that are not pending):"
                    $flywayInfoPending = $flywayInfo
                    $flywayInfoPending.migrations = $flywayInfoPending.migrations | Where-Object { $_.state -eq 'Pending' }
                    $flywayInfoPending | ConvertTo-Json -Depth 100

                    # Parameters for Flyway command.
                    $params = 
                    'migrate', 
                    "-workingDirectory=$flywayProjectDirectory",
                    "-url=$url",
                    "-user=$sqlServerInstanceUsername",
                    "-password=$sqlServerInstancePassword",
                    '-skipCheckForUpdate',
                    '-outOfOrder=true',
                    '-outputType=json'

                    if ($pipelineRun) {
                        Write-Information -Message "Execute Flyway migrate command"
                    }
                    else {
                        Write-Information -Message "Execute Flyway migrate command with following parameters:"
                        $params
                    }

                    $flywayMigrateJson = & 'flyway' @params
                    $flywayMigrate = $flywayMigrateJson | ConvertFrom-Json -Depth 100
                    
                    if ($null -eq $flywayMigrate) {
                        throw "Output of Flyway migrate command is null."
                    }

                    if ($null -ne $flywayMigrate.error) {
                        Write-Error -Message "Flyway migrate command failed:"
                        $flywayMigrateJson
                        throw $flywayMigrate.error.message
                    }

                    if ($null -eq $flywayInfo.migrations) {
                        Write-Information -Message "No migrations found in output of Flyway migrate command."
                        continue 
                    }

                    Write-Information -Message "Migrations found in output of Flyway migrate command."
                    $flywayMigrateJson
                }
                else {
                    Write-Information -Message "No flyway folder found at $flywayProjectDirectory, so no migration possible."

                }
                Write-Information -Message "** Finished Flyway migration for database $databaseName **"

            }
            catch {
                If ($migrationRun -eq 1) {
                    Write-Warning -Message "Flyway migration failed for database $databaseName retry will be done in next migration run"
                }
                else {
                    Write-Error -Message "Flyway migration failed for database $databaseName" -WithLog $true
                }
                $_.Exception.Message
                ++$migrationErrors
                Write-Warning -Message "Total migrations number of migration errors: $migrationErrors"
            }
            if ($pipelineRun) {
                Write-Host "##[endgroup]"
            }
        }
        # next migration run, if needed because of migrations error the first migration run
        If ($migrationErrors -gt 0 -and $migrationRun -eq 1) {
            $runMigrations = $true
            Write-Information -Message "Migrations will be rerun due to migration errors"
        }
        else {
            $runMigrations = $false 
        }
        ++$migrationRun
    }


}
catch {
    $_
    Write-Error -Message "Script $scriptName failed." -WithLog $true
}
finally {
    Write-Information -Message "** Finished script $scriptName **"
}