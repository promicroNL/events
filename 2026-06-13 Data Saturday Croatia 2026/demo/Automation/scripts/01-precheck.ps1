<#
.SYNOPSIS
  Validate prerequisites before running database provisioning scripts.
.DESCRIPTION
  Ensures configuration, credentials, and required modules are available
  before continuing with deployment.
#>

param(
    [string]$settingsFile = "../config/sqlmi-first.json",
    [string]$migrationsPath = "../database"
)

. "$PSScriptRoot/00-utils.ps1"

Write-Log "Running pre-checks..."

# Ensure configuration file can be loaded
try {
    $config = Get-Config -Path $settingsFile
    Write-Log "Loaded config for SQL MI '$($config.sqlServerName)'."
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}

# Ensure admin password is available
try {
    $null = Get-AdminPassword -Fallback $pwdDebug
    Write-Log "SQL MI admin password located." "DEBUG"
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}

# Verify Invoke-Sqlcmd is available
if (-not (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Log "Invoke-Sqlcmd not found. Install the SqlServer module." "ERROR"
    exit 1
}

Write-Log "Pre-checks completed successfully."
