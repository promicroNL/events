<#
.SYNOPSIS
  Stash the database by renaming it with the build name.
.DESCRIPTION
  Renames the current database using the build identifier so it can be
  restored or inspected later.
#>

param(
    [string]$settingsFile = "../config/sqlmi-first.json"
)

. "$PSScriptRoot/00-utils.ps1"

# Load configuration and admin password
$config = Get-Config -Path $settingsFile
$miFqdn = $config.sqlServerNameFqdn
$dbName = $config.databaseName
$adminPass = Get-AdminPassword -Fallback $pwdDebug

Write-Log "Starting stash for database '$dbName' on MI '$miFqdn' for build $buildName."

# Read existing BuildName extended property if present
$existingEp = Get-DatabaseBuildName -Config $config -Database $dbName -Password $adminPass

# Only stash when the existing BuildName matches the current build number.
# This prevents accidentally stashing a database from a different build.
if ($existingEp -eq $buildName) {
    if ([string]::IsNullOrWhiteSpace($buildName)) {
        $stashSuffix = if ($existingEp) { $existingEp } else { "stashed-$(Get-Date -Format yyyyMMddHHmmss)" }
    }
    else {
        $stashSuffix = $buildName
    }

    Rename-Database -Config $config -Database $dbName -NewName "${dbName}_$stashSuffix" -Password $adminPass | Out-Null
    Write-Log "Stash complete: '${dbName}_$stashSuffix'."
}
else {
    Write-Log "Stash skipped: BuildName EP '$existingEp' does not equal the build name '$buildName'." "ERROR"
}
