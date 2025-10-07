<#
.SYNOPSIS
  Verify that the target database contains expected data.
.DESCRIPTION
  Executes a simple query to validate that migrations produced the expected
  results.
#>

param(
    [string]$settingsFile = "../config/sqlmi-first.json"
)

. "$PSScriptRoot/00-utils.ps1"

# Load configuration and admin password
$config = Get-Config -Path $settingsFile
$adminPass = Get-AdminPassword -Fallback $pwdDebug

# Execute simple verification query
Write-Log "Running verification query..."
try {
    $result = Invoke-Sqlcmd -ServerInstance $config.sqlServerNameFqdn `
              -Database $config.databaseName `
              -Username $config.adminUser `
              -Password $adminPass `
              -Query "SELECT TOP 1 * FROM Hello" `
              -ErrorAction Stop
} catch {
    Write-Error "Verification query failed: $($_.Exception.Message)"
    exit 1
}

if (-not $result) {
    Write-Error "Verification query returned no rows." 
    exit 1
}

Write-Log "Verification succeeded." 
