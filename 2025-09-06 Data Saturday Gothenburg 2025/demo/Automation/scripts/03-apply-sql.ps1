<#
.SYNOPSIS
  Run SQL migration files against the target database.
.DESCRIPTION
  Executes each .sql migration file in order to apply schema changes to the
  database.
#>

param(
    [string]$settingsFile = "../config/sqlmi-first.json",
    [string]$migrationsPath = "../../Database/database/"
)

. "$PSScriptRoot/00-utils.ps1"

# Load configuration and admin password
$config = Get-Config -Path $settingsFile
$adminPass = Get-AdminPassword -Fallback $pwdDebug

if (-not (Test-Path $migrationsPath)) {
    Write-Log "Migrations path '$migrationsPath' not found" "ERROR"
    exit 1
}

# Execute each migration script in order
$files = Get-ChildItem -Path $migrationsPath -Filter "*.sql" | Sort-Object Name
if (-not $files) {
    Write-Log "No SQL migration files found in '$migrationsPath'." "WARN"
    return
}

foreach ($file in $files) {
    Write-Log "Running migration $($file.Name)..."
    try {
        Invoke-Sqlcmd -ServerInstance $config.sqlServerNameFqdn `
                      -Database $config.databaseName `
                      -Username $config.adminUser `
                      -Password $adminPass `
                      -InputFile $file.FullName `
                      -ErrorAction Stop
        Write-Log "Migration $($file.Name) completed."
    }
    catch {
        Write-Error "Migration $($file.Name) failed: $($_.Exception.Message)"
        exit 1
    }
}

Write-Log "Migration execution finished."
