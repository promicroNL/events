<#
.SYNOPSIS
  Remove stashed databases whose associated pipeline build completed successfully.

.DESCRIPTION
  Enumerates databases on the SQL MI that match the database database name with a
  build-number suffix. For each candidate, queries the Azure DevOps Build API to
  check whether the corresponding build has completed successfully. If so, the
  stashed database is dropped.
#>

param(
  [string]$settingsFile = "../config/sqlmi-first.json"
)

. "$PSScriptRoot/00-utils.ps1"

try {
  $ErrorActionPreference = 'Stop'

  # Load configuration and admin password
  $config = Get-Config -Path $settingsFile
  $dbName = $config.databaseName
  $adminPass = Get-AdminPassword -Fallback $pwdDebug

  # Prepare pipeline context for API calls
  $ctx = Get-PipelineContext
  $orgUrl = $ctx.OrgUrl
  $project = $ctx.Project
  $headers = $ctx.Headers

  # Find all databases that look like stashes of the database
  $query = @"
SELECT name
FROM sys.databases
WHERE name LIKE N'$($dbName)_%';
"@
  $stashedDbs = Invoke-Sql -Config $config -Database "master" -Query $query -Password $adminPass |
    Select-Object -ExpandProperty name

  foreach ($db in $stashedDbs) {
    $stashedBuildId = Get-DatabaseBuildId -Config $config -Database $db -Password $adminPass
    if ($stashedBuildId -notmatch '^\d+$') {
      Write-Log "Skipping '$db' - BuildId EP '$stashedBuildId' is missing or not numeric." "DEBUG"
      continue
    }

    $buildUrl = "$orgUrl/$project/_apis/build/builds/$stashedBuildId/?api-version=7.1"
    Write-Log "GET $buildUrl" "DEBUG"
    try {
      $build = Invoke-RestMethod -Method GET -Uri $buildUrl -Headers $headers
    }
    catch {
      Write-Log "Failed to query build $stashedBuildId : $($_.Exception.Message)" "WARN"
      continue
    }

    if ($build.status -eq 'completed' -and $build.result -in ('succeeded', 'failed')) {
      Write-Log "Dropping stashed database '$db' for succeeded build $stashedBuildId."
      $dropQuery = "DROP DATABASE [$db];"
      Invoke-Sql -Config $config -Database "master" -Query $dropQuery -Password $adminPass
    }
    else {
      Write-Log "Keeping '$db' - build status: $($build.status) result: $($build.result)" "DEBUG"
    }
  }

  exit 0
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}
